class Class
  module Vars
    module Object
      def cv; self.class; end
    end

    module Triggers
      def included(base)
        #puts "ClassVar included #{base.name}"
        base.extend Triggers
      end
    
      def extended(base)
        #puts "ClassVar extend #{base.name}"
        base.__send__ :include, Class::Vars::Object
      end
    end
    extend Triggers

    def cv; self; end
    def psuedo_class_var(var)
      self.class.__send__ :attr_accessor, "#{var}"
    end
    
  end
end
