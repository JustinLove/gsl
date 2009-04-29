module ClassVars
  module Object
    def cv; self.class; end
  end

  module SuperClass
    def included(base)
      #puts "ClassVar included #{base.name}"
      base.extend SuperClass
    end
  
    def extended(base)
      #puts "ClassVar extend #{base.name}"
      base.__send__ :include, ClassVars::Object
    end
  end

  module Class
    extend SuperClass
    
    def cv; self; end
    
    def psuedo_class_var(var)
      class <<self; self; end.__send__ :attr_accessor, "#{var}"
    end
  end
end
