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
        "State #{object_id}(#{@d.keys.count})"
      end
      
      def [](k)
        @d[k] || (@parent && @parent[k])
      end
      
      def []=(k, v)
        @d[k] = v
      end
      
      def merge
        State.new(@parent.parent).merge!(@parent).merge!(self)
      end
      
      def merge!(state)
        state.merge_into(self)
      end
      
      def merge_into(state)
        state.merge_data!(@d)
      end
      
      def merge_data!(hash)
        @d.merge!(hash)
        self
      end
      
      def merge_down!
        @parent.merge_data!(@d)
      end
    end
    
    class View
      attr_reader :state
      attr_reader :reality
      
      def initialize
        super
        @state = @reality = State.new
      end
      
      def to_s
        "View (#{@state})"
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
        raise "Can't ascend past reality" if @state == @reality
        @state = @state.parent
      end
      
      alias_method :begin, :descend
      alias_method :abort, :ascend
      
      def commit
        @state = @state.merge_down!
      end
      
      def checkpoint
        @reality = descend
      end
    end
  end
end
