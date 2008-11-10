module GSL
  class Component
    include Prototype
    extend Prototype
    attr_reader :name

    def self.hash(name, value)
      list = []
      value.each do|k,v|
        v.times {list << Component.new(k, name)}
      end
      array(name, list)
    end

    def self.array(name, value)
      value
    end

    def self.fixnum(name, value)
      list = []
      value.times {list << Component.new(name)}
      array(name, list)
    end

    @@actions = {}
    def self.define_action(name, proc)
      @@actions[name] = proc
    end

    def initialize(name, kind = nil)
      @name = name
      @kind = kind || name
    end

    def to_s
      @name.to_s
    end

    def discard_to(where)
      if (where.class.name == @kind)
        @home = where
      end
      return self
    end

    def discard
      @home.discard self
    end

    def to_proc
      @@actions[self.name]
    end
  end
end