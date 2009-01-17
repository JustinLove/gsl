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
      
      def clone
        State.new(@parent).merge_data!(@d)
      end
      
      def to_s
        "State #{object_id}[#{@d.keys.count}] < #{@parent.object_id}"
      end
      
      def pretty_print
        puts self
        puts @parent.pretty_print if @parent
      end
      
      def [](k)
        @d[k] || (@parent && @parent[k])
      end
      
      def []=(k, v)
        @d[k] = v
      end
      
      def merge
        @parent.clone.merge_data!(@d)
      end
      
      def merge_data!(hash)
        @d.merge!(hash)
        self
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
      
      def pretty_print
        @state.pretty_print
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
        raise "Can't commit past reality" if @state == @reality
        if (@state.parent == @reality)
          @reality = @state = @state.merge
        else
          @state = @state.merge
        end
      end
      
      def checkpoint
        @reality = descend
      end
    end
  end
end
