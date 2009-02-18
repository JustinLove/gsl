module Properties
  def as_property(named)
    define_method(named) do |*parameters|
      value, *ignored = *parameters
      if (value)
        instance_variable_set("@#{named}", value)
      else
        instance_variable_get("@#{named}")
      end
    end
  end
  def as_proc(named)
    define_method(named) do |&proc|
      if (proc)
        instance_variable_set("@#{named}", proc)
      else
        instance_variable_get("@#{named}").call
      end
    end
  end
end
