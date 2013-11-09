require 'spec_helper'


#tests = Proc.new do
share_examples_for 'Neo4j::NodeMixin' do
  before(:all) do
    Neo4j::Wrapper::Labels._wrapped_classes = []
    Neo4j::Wrapper::Labels._wrapped_labels = nil

    class TestClass
      include Neo4j::NodeMixin
    end

    Neo4j::Label.create(:IndexedTestClass).drop_index(:name)

    class IndexedTestClass
      include Neo4j::NodeMixin
      index :name  # will index using the IndexedTestClass label
    end

    module SomeLabelMixin
      def self.mapped_label_name
        :some_label
      end
    end

    class SomeLabelClass
      include Neo4j::NodeMixin
      include SomeLabelMixin
    end
  end

  after(:all) do
    Object.send(:remove_const, :IndexedTestClass)
    Object.send(:remove_const, :TestClass)
  end

    describe 'create' do
      it "sets neo_id" do
        p = TestClass.create
        p.neo_id.should be_a(Fixnum)
      end

      it 'automatically sets a label' do
        p = TestClass.create
        p.labels.to_a.should == [:TestClass]
      end

      it "sets label for mixin classes" do
        p = SomeLabelClass.create
        p.labels.to_a.should =~ [:SomeLabelClass, :some_label]
      end
    end

    describe 'load' do
      it 'can load a node' do
        p = TestClass.create
        id = p.neo_id
        loaded = Neo4j::Node.load(id)
        loaded.neo_id.should == id
        loaded.should == p
        #loaded.class.should == TestClass
      end
    end

    describe 'find_all' do
      it "finds it without an index" do
        p = TestClass.create
        TestClass.find_all.to_a.should include(p)
      end

      describe 'when indexed' do
        it 'can find it without using the index' do
          andreas = IndexedTestClass.create(name: 'andreas')
          result = IndexedTestClass.find_all
          result.should include(andreas)
        end

        it 'does not find it if it has been deleted' do
          jimmy = IndexedTestClass.create(name: 'jimmy')
          result = IndexedTestClass.find_all
          result.should include(jimmy)
          jimmy.del
          IndexedTestClass.find_all.should_not include(jimmy)
        end
      end
    end

  describe 'find' do
    it "finds it without an index" do
      p = TestClass.create
      TestClass.find_all.to_a.should include(p)
    end

    describe 'when indexed' do
      it 'can find it using the index' do
        kalle = IndexedTestClass.create(name: 'kalle')
        result = IndexedTestClass.find(:name, 'kalle')
        result.should include(kalle)
      end

      it 'does not find it if deleted' do
        kalle2 = IndexedTestClass.create(name: 'kalle2')
        result = IndexedTestClass.find(:name, 'kalle2')
        result.should include(kalle2)
        kalle2.del
        IndexedTestClass.find(:name, 'kalle2').should_not include(kalle2)
      end
    end

    describe 'when finding using a Module' do

    end
  end


end

share_examples_for 'Neo4j::NodeMixin with Mixin Index'do
  before(:all) do
    Neo4j::Wrapper::Labels._wrapped_classes = []
    Neo4j::Wrapper::Labels._wrapped_labels = nil

    Neo4j::Label.create(:BarIndexedLabel).drop_index(:baaz)
    sleep(1) # to make it possible to search using this module (?)

    module BarIndexedLabel
      extend Neo4j::Wrapper::Labels::ClassMethods # to make it possible to search using this module (?)
      begin
        index :baaz
      rescue => e
        puts "WARNING: sometimes neo4j has a problem with removing and adding indexes in tests #{e}" # TODO
      end
    end

    class TestClassWithBar
      include Neo4j::NodeMixin
      include BarIndexedLabel
    end
  end


  it "can be found using the Mixin Module" do
    hej = TestClassWithBar.create(:baaz => 'hej')
    BarIndexedLabel.find(:baaz, 'hej').should include(hej)
    TestClassWithBar.find(:baaz, 'hej').should include(hej)
    BarIndexedLabel.find(:baaz, 'hej2').should_not include(hej)
    TestClassWithBar.find(:baaz, 'hej2').should_not include(hej)
  end
end

describe 'Neo4j::NodeMixin, server', api: :server do
  it_behaves_like 'Neo4j::NodeMixin'
  it_behaves_like "Neo4j::NodeMixin with Mixin Index"
end

describe 'Neo4j::NodeMixin, embedded', api: :embedded do
  it_behaves_like 'Neo4j::NodeMixin'
  it_behaves_like "Neo4j::NodeMixin with Mixin Index"
end