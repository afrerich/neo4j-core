require "neography"

module Neo4j
  module Session
    class Rest
      attr_reader :neo, :url
      
      def initialize(url = "http://localhost:7474")
        @neo = Neography::Rest.new url
        @url = url
      end

      # These methods make no sense for a rest server so we just return true to make our specs happy
      def start
        true
      end

      alias :stop :start
      alias :running? :start

      def create_node(attributes, labels)
        node = @neo.create_node(attributes)
        return nil if node.nil?
        @neo.add_label(node, labels)
        Neo4j::Node::Rest.new(node, self)
      end

      def load(id)
        node = @neo.get_node(id)
        Neo4j::Node::Rest.new(node, self)
      end

      def load_rel(id)
        rel = @neo.get_relationship(id)
        Relationship::Rest.new(rel, self)
      end

      def begin_tx
        # Fetch the transaction associated with session. If none is found then begin a new one.
        # Thread.current[ID_MAPPER] || Thread.current[ID_MAPPER] = Transaction::Rest.new(self)
        Transaction::Rest.new self
      end

      def to_s
        @url
      end

      # private
        # ID_MAPPER = "Neo4j::#{to_s}"
    end
  end
end