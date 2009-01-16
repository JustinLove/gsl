module GSL
  module World
    class State
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
      def to_s
        "View"
      end
    end
  end
end
