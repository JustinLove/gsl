module GSL
  class Resource
    module Value
      def set(n)
        if self.class.range.include?(n)
          @value = n
        else
          raise 'resource out of range'
        end
      end

      def if_gain(n)
        if self.class.range.include?(@value+n)
          return @value + n
        else
          raise Insufficient.new(@name, @value, n)
        end
      end
  
      def if_lose(n = :all)
        if (n == :all)
          n = @value
        end
        self.if_gain(-n)
      end
  
      def gain(n)
        old = @value
        @value = self.class.range.bound(@value+n)
        return @value - old
      end
  
      def lose(n = :all)
        n = @value if n == :all
        m = @value
        -self.gain(-n)
      end
    end
  end
end
