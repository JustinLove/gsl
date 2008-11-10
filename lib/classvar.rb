class Object
  def cv; self.class; end
end

class Class
  def cv; self; end
  def psuedo_class_var(var)
    self.class.__send__ :attr_accessor, "#{var}"
  end
end