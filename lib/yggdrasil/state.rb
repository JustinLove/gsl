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
    
    module Tracing
      @@calls = 0
      @@lookups = 0
      
      def calls; @@calls; end

      def self.report
        "#{@@calls} calls, #{@@lookups} lookups, #{@@calls.to_f / @@lookups} avg"
      end

      def [](k)
        @@calls +=1
        if (@d[k].nil?)
          upcall(k)
        else
          @@lookups += 1
          hit(k)
        end
      end
      
      def upcall(k)
        (@parent && @parent[k])
      end
      
      def hit(k)
        @d[k]
      end
    end
    
    module Logging
      @@called = 0
      def self.included(base)
        @@log = File.open("#{base}.log", 'w')
      end
      def hit(k)
        @@log.puts "#{k.to_s.gsub(/\d/,'')} #{calls - @@called}"
        @@called = calls
        @d[k]
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