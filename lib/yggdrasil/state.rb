module Yggdrasil
  class State
    module Base
      attr_reader :parent
      attr_reader :depth
      attr_accessor :name
    
      def derive(_name = nil)
        State.new(self, _name)
      end
    
      def clone
        State.new(@parent).merge_data!(@d)
      end
    
      def to_s
        "State(#{depth}) #{name}[#{@d.keys.count}] < #{@parent && @parent.name}"
      end
    
      def inspect
        "State(#{depth}) #{name}[#{@d.keys.count}: #{@d.keys[0,5]}] < #{@parent && @parent.name}"
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
          upcall(k)
        else
          hit(k)
        end
      end
      
      def upcall(k)
        (@parent && @parent[k])
      end
      
      def hit(k)
        @d[k]
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
    
    module Tracing
      @@calls = 0
      @@lookups = 0
      @@writes = 0
      @@states = 0
      
      def calls; @@calls; end

      def self.report
        "#@@states states, #@@writes writes, #@@calls calls, #@@lookups lookups, " +
          "#{@@calls.to_f / @@lookups} avg, #{@@lookups.to_f / @@writes} r/w; " +
          "#{@@lookups.to_f / @@states} r/s #{@@writes / @@states} w/s"
      end

      def [](k)
        @@calls +=1
        super
      end

      def []=(k, v)
        @@writes += 1
        super
      end
      
      def hit(k)
        @@lookups += 1
        super
      end
      
      def initialize(*args)
        @@states += 1
        super
      end
    end
    
    module Logging
      @@depth = 0

      def self.included(base)
        @@log = File.open("#{base}.log", 'w')
      end

      def [](k)
        @@depth +=1
        super
      end

      def hit(k)
        @@log.puts "#{k.to_s.gsub(/\d/,'')} #{@@depth}"
        @@depth = 0
        super
      end
    end
    
    module ReadCache
      def upcall(k)
        @d[k] = super
      end
    end
    
    include Base

    def initialize(_parent = nil, _name = nil)
      super()
      @d = {}
      @parent = _parent
      @name = _name || object_id.to_s
      @depth = 1
      @depth += _parent.depth if _parent
    end
    
  end
end