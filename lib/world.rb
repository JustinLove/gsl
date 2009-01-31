module GSL
  module World
    class State
      attr_reader :parent
      attr_reader :depth
      attr_accessor :name
      
      def initialize(_parent = nil, _name = nil)
        super()
        @d = {}
        @parent = _parent
        @name = _name || object_id.to_s
        @depth = 1
        @depth += _parent.depth if _parent
      end
      
      def derive(_name = nil)
        State.new(self, _name)
      end
      
      def clone
        State.new(@parent).merge_data!(@d)
      end
      
      def to_s
        "State(#{depth}) #{name}[#{@d.keys.count}] < #{@parent && @parent.name}"
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
      
      def update(k, default = nil, &proc)
        v = self[k]
        v = v.dup if v.frozen?
        v = default if v.nil?
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
      
      def descend(_name = nil)
        @state = @state.derive(_name) #.tap {|s| puts "#{@state} + #{s}"}
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
      
      def checkpoint(_name = nil)
        @reality = descend(_name)
      end
      
      def branch(_name = nil)
        hidden = [@state, @reality]
        descend(_name)
        yield
        b = @state
        @state, @reality = hidden
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
      
      def update(k, default = nil, &proc)
        @world.state.update(id_card(k), default, &proc)
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
