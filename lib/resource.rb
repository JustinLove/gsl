module GSL
  class Resource
    class << self
      alias :class_name :name
      attr_accessor :name, :range, :option
      def to_s
        if @name then
          "#{@name} #{@range}"
        else
          super
        end
      end
      def define(name)
        const_name = name.to_s.capitalize
        if (const_defined?(const_name))
          return const_get(const_name)
        end
        return const_set(const_name, Class.new(self) do
          @name = name
          @range = 0..Infinity
          @option = nil
        end)
      end
    end

    include Prototype
    extend Properties

    attr_accessor :value
    def name
      self.class.name
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
          include Value_Resource
        end
        self.set(n)
      elsif (n.kind_of? Enumerable)
        class << self
          include Set_Resource
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
  
  end

  class InsufficientResources < RuntimeError
    def initialize(r, has = 0, req = 0)
      @resource = r
      @has = has
      @req = req
    end
  
    def to_s
      "Insufficient #{@resource}, #{@has} < #{@req}"
    end
  end

  class FailedPrecondition < RuntimeError
    def initialize(message = nil)
      @message = message
    end
  
    def to_s
      "Precondition '#{@message}' Failed"
    end
  end
end
