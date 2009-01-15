module GSL
  module World
    class State
      def initialize
        super
        @d = {}
      end
      
      def to_s
        "State #{object_id}"
      end
      
      def [](k)
        @d[k]
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
