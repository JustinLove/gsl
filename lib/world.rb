module GSL
  module World
    class State
      attr_reader :parent
      
      def initialize(_parent = nil)
        super()
        @d = {}
        @parent = _parent
      end
      
      def derive
        State.new(self)
      end
      
      def to_s
        "State #{object_id}"
      end
      
      def [](k)
        @d[k] || (@parent && @parent[k])
      end
      
      def []=(k, v)
        @d[k] = v
      end
    end
    
    class View
      attr_accessor :state
      
      def initialize
        super
        @state = State.new
      end
      
      def to_s
        "View"
      end
      
      def [](k)
        @state[k]
      end
      
      def []=(k, v)
        @state[k] = v
      end
      
      def descend
        @state = @state.derive
      end
      
      def ascend
        @state = @state.parent
      end
    end
  end
end
