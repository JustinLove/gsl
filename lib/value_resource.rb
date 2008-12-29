module GSL
  class Resource
    module Value
      def set(n)
        n = wrap(n)
        if self.class.range.include?(n)
          @value = n
        else
          raise 'resource out of range'
        end
      end

      def if_gain(n)
        n = wrap(n)
        if self.class.range.include?(@value+n)
          return @value + n
        else
          raise Insufficient.new(name, @value, n)
        end
      end
  
      def if_lose(n = :all)
        self.if_gain(-wrap(n))
      end
  
      def gain(n)
        old = @value
        @value = self.class.range.bound(@value+wrap(n))
        return @value - old
      end
  
      def lose(n = :all)
        m = @value
        -self.gain(-wrap(n))
      end
    end
  end
end
