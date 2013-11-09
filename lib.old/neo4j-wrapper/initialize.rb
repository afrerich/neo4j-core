module Neo4j::Wrapper::Initialize

  # Init this node with the specified java neo node
  # @param [Neo4j::Node] java_node the node this instance wraps
  def init_on_load(java_node)
    @_unwrapped_node = java_node
  end


  # @return [Neo4j::Node] Returns the org.neo4j.graphdb.Node wrapped object
  # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Node
  def _unwrapped_node
    @_unwrapped_node
  end

  # Implements the Neo4j::Node#wrapper and Neo4j::Relationship#wrapper method
  # so that we don't have to care if the node is wrapped or not.
  # @return self
  def wrapper
    self
  end

  alias_method :_unwrapped_entity, :_unwrapped_node


  module ClassMethods

    # Creates a new node or loads an already existing Neo4j node.
    #
    # You can use two callback method to initialize the node
    # init_on_load - this method is called when the node is loaded from the database
    # init_on_create - called when the node is created, will be provided with the same argument as the new method
    #
    # == Does
    # * creates a neo4j node java object (in @_unwrapped_node)
    #
    # If you want to provide your own initialize method you should instead implement the
    # method init_on_create method.
    #
    # @example Create your own Ruby wrapper around a Neo4j::Node java object
    #   class MyNode
    #     include Neo4j::NodeMixin
    #   end
    #
    #   node = MyNode.create(:name => 'jimmy', :age => 23)
    #
    # @example Using your own initialize method
    #   class MyNode
    #     include Neo4j::NodeMixin
    #
    #     def init_on_create(name, age)
    #        self[:name] = name
    #        self[:age] = age
    #     end
    #   end
    #
    #   node = MyNode.create('jimmy', 23)
    #
    # @param args typically a hash of properties, but could be anything which will be given to the init_on_create method
    # @return the object return from the super method
    def create(*args)
      session = Neo4j::Session.current
      props = args[0] if args[0].is_a?(Hash)
      labels = self.respond_to?(:mapped_label_names) ? mapped_label_names : []
      node = session.create_node(props, labels)
      wrapped_node = new()
#          Neo4j::IdentityMap.add(node, wrapped_node)
      wrapped_node.init_on_load(node)
      wrapped_node
    end

  end

end


