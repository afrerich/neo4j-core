share_examples_for "Neo4j::Node with tx" do
  let(:node_a) { Neo4j::Node.create(name: 'a') }
  let(:node_b) { Neo4j::Node.create(name: 'b') }
  let(:node_c) { Neo4j::Node.create(name: 'c') }

  context "inside a transaction" do

    describe 'Neo4j::Node.create' do
      it 'creates a new node' do
        n = Neo4j::Transaction.run do
          Neo4j::Node.create name: 'jimmy'
        end
        n[:name].should == 'jimmy'
      end

      it 'does not have any relationships' do
        Neo4j::Transaction.run do
          n = Neo4j::Node.create
          n.rels.should be_empty
          n
        end.rels.should be_empty
      end
    end

    describe 'create_rel' do
      it 'creates the relationship' do
        rel = Neo4j::Transaction.run do
          node_a = Neo4j::Node.create name: 'a'
          node_b = Neo4j::Node.create name: 'b'
          rel_a = node_a.create_rel(:best_friend, node_b, age: 42)
          node_a.rels.to_a.should == [rel_a]
          rel_a[:age].should == 42
          rel_a
        end
        rel[:age].should == 42
      end

    end
  end

end
