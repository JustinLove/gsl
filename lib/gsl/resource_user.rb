require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{classvar resource component ygg}

module GSL
  module ResourceUser
    extend Yggdrasil::Citizen::Class
    
    def self.included(base)
      #puts base.name
      base.extend ResourceUser::Class
      base.psuedo_class_var :components
      base.psuedo_class_var :resources
      base.cv.components = {}
      base.cv.resources = []
    end

    def self.forward(method)
      define_method method do |n,resource|
        if cv.resources.include? resource
          #puts "#{self.to_s} #{method} #{n} #{resource}" unless (method.to_s.match(/^if/))
          @resources[resource].__send__ method, n
        elsif forward_to
          #puts "#{self.to_s} #{method} #{n} #{resource}"
          forward_to.__send__ method, n, resource
        else
          Language.error "#{self.to_s} can't #{method} #{resource}"
        end
      end
    end

    module Class
      include ClassVars::Class
      def make_components(name, value)
        cv.components[name] = Component.from(name, value)
      end

      def make_resource(name, option = nil, &proc)
        cv.resources << name unless cv.resources.include?(name)
        r = Resource.define(name, option, &proc)
      end
      
      def resource_hints(weights)
        weights.each do |resource, weight|
          Resource.get(resource).option[:hint] = weight
        end
      end
    end

    def initialize
      super()
      create_resources
    end
    
    def create_resources
      @resources = Hash.new do |hash, key|
        hash[key] = Resource.define(key).new(self)
        if (cv.components.keys.include? key)
          cv.resources << key unless cv.resources.include?(key)
          hash[key].set cv.components[key].dup.map {|c| c.reset(@world); c}
        elsif (hash[key].class.option[:initial])
          begin
            hash[key].set hash[key].class.option[:initial].dup
          rescue
            hash[key].set hash[key].class.option[:initial]
          end
        end
        hash[key]
      end
    end
    
    def to_s
      "#{self.class} with #{@resources && @resources.keys}"
    end

    def respond_to?(method)
      if (cv.resources.include?(method))
        return true
      elsif (forward_to)
        return forward_to.respond_to?(method) || super
      end
      super
    end

    def method_missing(method, *args, &block)
      if (cv.resources.include?(method))
        #puts 'returning ' + method.to_s
        return @resources[method]
      elsif (cv.components.keys.include?(method))
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
    
    def names(array)
      array.map {|c| c.name}
    end
  
    def must_have(&condition)
      Game.illegal :FailedPrecondition unless (instance_eval(&condition))
    end

    def may_not(&condition)
      Game.illegal :NotAllowed if (instance_eval(&condition))
    end
    
    def utility(name, &proc)
      ResourceUser.__send__(:define_method, name, &proc)
    end
    
    def action(name = "?", &proc)
      Action.new(name, &proc)
    end
    
    def no_action
      NoAction.new
    end
    
    def probability(component, &proc)
      c = cv.components[component]
      c.find_all(&proc).length.to_f / c.length
    end
  end
end
