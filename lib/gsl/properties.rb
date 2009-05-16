module Properties
  def as_property(named)
    class_eval <<-PROP
      def #{named}(value = nil)
        if (value)
          @#{named} = value
        else
          @#{named}
        end
      end
      PROP
  end
  def as_proc(named)
    class_eval <<-PROC
      def #{named}(&proc)
        if (proc)
          @#{named} = proc
        else
          @#{named}.call
        end
      end
      PROC
  end
end
