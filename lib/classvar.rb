class Class
  module Vars
    module Object
      def cv; self.class; end
    end

    def self.include(base)
      #puts "included #{base.name}"
      base.__send__ :include, Class::Vars::Object
    end
    
    def self.extended(base)
      #puts "extending #{base.name}"
      base.__send__ :include, Class::Vars::Object
    end
    
    def cv; self; end
    def psuedo_class_var(var)
      self.class.__send__ :attr_accessor, "#{var}"
    end
    
  end
end
