require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{prototype classvar misc set_resource value_resource}

module GSL
  class Resource
    class << self
      alias :class_name :name
      attr_accessor :name, :option
      def to_s
        if @name then
          "#{@name} #{@range}"
        else
          super
        end
      end
      def define(name, option = {}, &proc)
        const_name = name.to_s.capitalize
        if (const_defined?(const_name))
          return const_get(const_name)
        end
        return const_set(const_name, Class.new(self) do
          @name = name
          @option = option || {}
          if (!proc.nil?)
            include(Module.new(&proc))
          end
        end)
      end
      def range
        if @option[:range]
          @option[:range]
        else
          0..Infinity
        end
      end
    end

    include Prototype

    attr_accessor :value
    def name
      self.class.name
    end
    
    def initialize(owner)
      super()
      @owner = owner
    end

    def method_missing(method, *args, &proc)
      if @value.respond_to? method
        return @value.__send__ method, *args, &proc
      end
      super
    end

    def to_s
       "#{name}:#{@value}"
    end

    def set(n)
      if (n.kind_of? Numeric)
        class << self
          include Resource::Value
        end
        self.set(n)
      elsif (n.kind_of? Enumerable)
        class << self
          include Resource::Set
        end
        self.set(n)
      else
        raise "can't have that kind of resource"
      end
    end

    def must_gain(n)
      @value = if_gain(n)
    end

    def must_lose(n)
      old = @value
      @value = if_lose(n)
      return old - @value
    end
  
    def pay(n = :all)
      must_lose(n)
    end
  
    def wrap(n)
      n = @value if n == :all
      if (n.kind_of?(Symbol) && @owner.respond_to?(n))
        n = @owner.__send__(n)
      end
      if (n.kind_of?(Resource))
        return n.value
      else
        return n
      end
    end

    class Insufficient < GamePlayException
      def initialize(r, has = 0, req = 0)
        super()
        @resource = r
        @has = has
        @req = req
      end

      def to_s
        "Insufficient #{@resource}, #{@req} < #{@has}"
      end
    end
  end
end
