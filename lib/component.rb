module GSL
  class Component
    include Prototype
    extend Prototype
    attr_reader :name

    class << self
      def hash(name, value)
        list = []
        value.each do|k,v|
          v.times {list << Component.new(k, name)}
        end
        array(name, list)
      end

      def array(name, value)
        value
      end

      def fixnum(name, value)
        list = []
        value.times {list << Component.new(name)}
        array(name, list)
      end

      @@actions = {}
      def define_action(name, proc)
        @@actions[name] = proc
      end
    end
     
    attr_accessor :in
     
    def initialize(name, kind = nil)
      @name = name
      @kind = kind || name
      @in = nil
    end

    def to_s
      "#{@name}(#{@in})"
    end

    def discard_to(where)
      if (where.class.name == @kind)
        @home = where
      end
      return self
    end

    def discard
      @in.lose self if @in
      @in = @home
      @home.discard self
    end

    def to_proc
      @@actions[self.name]
    end
  end
end
