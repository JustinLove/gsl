module GSL
  module ResourceUser
    def self.included(base)
      base.extend ResourceUser::Class
      base.psuedo_class_var :components
      base.psuedo_class_var :resources
      base.cv.components = {}
      base.cv.resources = []
    end

    def self.forward(method)
      define_method method do |n,resource|
        if cv.resources.include? resource
          if (!method.to_s.match(/^if/))
            #puts "#{self.to_s} #{method} #{n} #{resource}"
          end
          @resources[resource].__send__ method, n
        elsif forward_to
          #puts "#{self.to_s} #{method} #{n} #{resource}"
          forward_to.__send__ method, n, resource
        else
          raise "#{self.to_s} can't #{method} #{resource}"
        end
      end
    end

    module Class
      def make_components(name, value)
        cv.components[name] = Component.send(value.class.name.downcase, name, value)
      end

      def make_resource(name, range = 0..Infinity, option = nil, &proc)
        cv.resources << name
        r = Resource.define(name)
        r.range = range
        r.option = option
        if (!proc.nil?)
          r.__send__ :include, Module.new(&proc)
        end
        r
      end
    end

    def resource_init
      @resources = Hash.new do |hash, key|
        hash[key] = Resource.define(key).new(self)
        if (cv.components.keys.include? key)
          hash[key].set deep_copy(cv.components[key])
        end
        hash[key]
      end
    end

    def respond_to?(method)
      if (@resources && @resources.keys.include?(method))
        return true
      elsif (forward_to)
        return forward_to.respond_to?(method) || super
      end
      super
    end

    def method_missing(method, *args, &block)
      if (@resources && @resources.keys.include?(method))
        #puts 'returning ' + method.to_s
        return @resources[method]
      elsif (forward_to && forward_to.respond_to?(method))
        return forward_to.__send__(method, *args, &block)
      end
      super
    end
  
    def set_to(n, *resources)
      resources.each {|r| set n, r }
    end

    #expected to be overridden, but having a checkable value
    #  beats calling respond_to?
    def forward_to; false; end

    forward :set
    forward :gain
    forward :lose
    forward :must_gain
    forward :must_lose
    forward :if_gain
    forward :if_lose
    forward :pay
  
    def has_resource?(resource)
      @resources.keys.include? resource
    end
    
    def resource(resource)
      @resources[resource]
    end
  
    def must_have(&condition)
      if !(instance_eval &condition)
        raise FailedPrecondition
      end
    end
  end
end
