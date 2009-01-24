module GSL
  module World
    class State
      attr_reader :parent
      attr_reader :depth
      
      def initialize(_parent = nil)
        super()
        @d = {}
        @parent = _parent
        @depth = 1
        @depth += _parent.depth if _parent
      end
      
      def derive
        State.new(self)
      end
      
      def clone
        State.new(@parent).merge_data!(@d)
      end
      
      def to_s
        "State(#{depth}) #{object_id}[#{@d.keys.count}] < #{@parent.object_id}"
      end
      
      def pretty_print(pp = nil)
        if (pp)
          super
        else
          puts self
          puts @parent.pretty_print if @parent
        end
      end
      
      def [](k)
        if (@d[k].nil?)
          (@parent && @parent[k])
        else
          @d[k]
        end
      end
      
      def []=(k, v)
        @d[k] = v.freeze
      end
      
      def update(k, &proc)
        v = self[k]
        v = v.dup if v.frozen?
        self[k] = proc.call(v)
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
      
      def pretty_print(pp = nil)
        if (pp)
          super
        else
          @state.pretty_print
        end
      end
      
      def [](k)
        @state[k]
      end
      
      def []=(k, v)
        @state[k] = v
      end
      
      def descend
        @state = @state.derive #.tap {|s| puts "#{@state} + #{s}"}
      end
      
      def ascend
        raise "Can't ascend past reality" if @state == @reality
        #puts "#{@state} - #{@state.parent}"
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
      
      def branch
        hidden = @state
        descend
        yield
        b = @state
        @state = hidden
        return b
      end
      
      def switch(w)
        @reality = @state = w
      end
    end
    
    class Passport
      attr_accessor :world
      
      def initialize(owner)
        @world = owner.world
        super()
        @owner = owner
        @oid = owner.object_id.to_s
      end
      
      def to_s
        "Passport #{@oid} for #{@owner}"
      end
      
      def id_card(key)
        @oid + key.to_s
      end
      
      def [](k)
        @world[id_card(k)]
      end
      
      def []=(k, v)
        @world[id_card(k)] = v
      end
      
      def update(k, &proc)
        @world.state.update(id_card(k), &proc)
      end
    end
    
    module Citizen
      module Object
        attr_reader :world
        
        def initialize
          super
          @w = Passport.new(self)
        end
        
        def to_s
          "Citizen #{object_id} of #{@world}"
        end
        alias_method :citizen_s, :to_s
      end

      module SuperClass
        def included(base)
          #puts "Citizen included #{base.name}"
          base.extend SuperClass
        end

        def extended(base)
          #puts "Citizen extend #{base.name}"
          base.__send__ :include, Citizen::Object
        end
      end

      module Class
        extend SuperClass
        
        def ver_writer(var)
          self.__send__ :define_method, "#{var}=" do |v|
            @w[var] = v
          end
        end
        
        def ver_reader(var)
          self.__send__ :define_method, var do
            @w[var]
          end
        end
        
        def ver_accessor(var)
          ver_reader(var)
          ver_writer(var)
        end
      end
    end
  end
end
