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
      
      def pretty_print(pp = nil)
        if (pp)
          super
        else
          puts self
          puts @parent.pretty_print if @parent
        end
      end
      
      def [](k)
        @d[k] || (@parent && @parent[k])
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
      def initialize(owner)
        super()
        @owner = owner
        @oid = owner.object_id.to_s
        @world = owner.world
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
      
      def method_missing(method, v = nil)
        if (method.to_s[-1,1] == '=')
          self[method.to_s.chop] = v
        else
          self[method]
        end
      end
    end
    
    module Citizen
      module Object
        attr_reader :world
        
        def to_s
          "Citizen #{object_id} of #{@world}"
        end
        alias_method :citizen_s, :to_s
        
        def id_card(var)
          self.object_id.to_s + var.to_s
        end
        
        def w(var, v = nil, &proc)
          if (proc)
            @world.state.update(id_card(var), &proc)
          elsif (v)
            @world[id_card(var)] = v
          else
            @world[id_card(var)]
          end
        end
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
            @world[self.object_id.to_s + var.to_s] = v
          end
        end
        
        def ver_reader(var)
          self.__send__ :define_method, var do
            @world[self.object_id.to_s + var.to_s]
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
