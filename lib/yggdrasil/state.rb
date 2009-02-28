module Yggdrasil
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
    
    @@calls = 0
    @@depth = 0
    @@lookups = 0
    @@log = File.open('ygg.log', 'w')
    def self.report
      "#{@@calls} calls, #{@@lookups} lookups, #{@@calls / @@lookups} avg"
    end
    
    def [](k)
      @@calls +=1
      @@depth += 1
      if (@d[k].nil?)
        (@parent && @parent[k])
      else
        @@lookups += 1
        @@log.puts @@depth
        @@depth = 0
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
end