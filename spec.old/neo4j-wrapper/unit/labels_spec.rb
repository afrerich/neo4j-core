require 'spec_helper'

describe Neo4j::Wrapper::Labels do
  before(:all) do
    @old_classes = Neo4j::Wrapper::Labels._wrapped_classes
    @old_labels = Neo4j::Wrapper::Labels._wrapped_labels
    Neo4j::Wrapper::Labels._wrapped_classes = []
    Neo4j::Wrapper::Labels._wrapped_labels = nil

    @classA = Class.new do
      include Neo4j::Wrapper::Labels
      def self.mapped_label_name; "A"; end
    end

    @classB = Class.new do
      include Neo4j::Wrapper::Labels
      def self.mapped_label_name; "B"; end
    end
  end

  after(:all) do
    # restore
    Neo4j::Wrapper::Labels._wrapped_classes = @old_classes
    Neo4j::Wrapper::Labels._wrapped_classes = @old_labels
  end

  describe 'include' do

    describe '_wrapped_classes' do

      it "store included classes" do
        Neo4j::Wrapper::Labels._wrapped_classes
        Neo4j::Wrapper::Labels._wrapped_classes.should =~ [@classA, @classB]
      end
    end

    describe '_wrapped_labels' do

      it "returns a hash of labels and classes" do
        Neo4j::Wrapper::Labels._wrapped_labels[:A].should == @classA
        Neo4j::Wrapper::Labels._wrapped_labels[:B].should == @classB
      end
    end

    describe "index" do
      it "index using the Neo4j::Label object" do
        pending
        clazz = Class.new do
          extend Neo4j::Wrapper::Labels::ClassMethods
          def self.to_s
            "MyClass"
          end
        end
        clazz.should_receive(:fooo)
        clazz.index(:me)

      end
    end
  end

  describe Neo4j::Wrapper::Labels::ClassMethods do

    describe 'mapped_label_name' do
      it "return the class name if not given a label name" do
        clazz = Class.new do
          extend Neo4j::Wrapper::Labels::ClassMethods
          def self.to_s
            "MyClass"
          end
        end
        clazz.mapped_label_name.should == :MyClass
      end
    end

    describe 'set_mapped_label_name' do
      it "sets the label name and overrides the class name" do
        clazz = Class.new do
          extend Neo4j::Wrapper::Labels::ClassMethods
          def self.to_s
            "MyClass"
          end
        end
        clazz.set_mapped_label_name("foo")
        clazz.mapped_label_name.should == :foo
      end
    end

    describe 'labels' do
      it "returns Neo4j::Label objects"
    end

    describe 'label' do
      it "wraps the mapped_label_name in a Neo4j::Label object" do
        clazz = Class.new do
          extend Neo4j::Wrapper::Labels::ClassMethods
          def self.to_s
            "MyClass"
          end
        end

        Neo4j::Label.should_receive(:create).with(:MyClass).and_return('foo')
        clazz.mapped_label.should == 'foo'
      end
    end

    describe 'mapped_label_names' do

      it 'returns the label of a class' do
        clazz = Class.new do
          extend Neo4j::Wrapper::Labels::ClassMethods
          def self.to_s
            "mylabel"
          end
        end
        clazz.mapped_label_names.should == [:mylabel]
      end

      it "returns all labels for inherited ancestors which have a label method" do
        baseClass = Class.new do
          def self.mapped_label_name
            "base"
          end
        end

        middleClass = Class.new(baseClass) do
          extend Neo4j::Wrapper::Labels::ClassMethods

          def self.mapped_label_name
            "middle"
          end
        end

        topClass = Class.new(middleClass) do
          extend Neo4j::Wrapper::Labels::ClassMethods

          def self.mapped_label_name
            "top"
          end
        end

        # notice the order is important since it will try to load and map in that order
        middleClass.mapped_label_names.should == [:middle, :base]
        topClass.mapped_label_names.should == [:top, :middle, :base]
      end

      it "returns all labels for included modules which have a label class method" do
        module1 = Module.new do
          def self.mapped_label_name
            "module1"
          end
        end

        module2 = Module.new do
          def self.mapped_label_name
            "module2"
          end
        end

        clazz = Class.new do
          extend Neo4j::Wrapper::Labels::ClassMethods
          include module1
          include module2

          def self.to_s
            "module"
          end
        end

        clazz.mapped_label_names.should =~ [:module, :module1, :module2]
      end

    end
  end
end
