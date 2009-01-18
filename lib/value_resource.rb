module GSL
  class Resource
    module Value
      def set(n)
        n = wrap(n)
        if self.class.range.include?(n)
          self.value = n
        else
          raise 'resource out of range'
        end
      end

      def if_gain(n)
        n = wrap(n)
        if self.class.range.include?(self.value+n)
          return self.value + n
        else
          raise Insufficient.new(name, self.value, n)
        end
      end
  
      def if_lose(n = :all)
        self.if_gain(-wrap(n))
      end
  
      def gain(n)
        old = self.value
        self.value = self.class.range.bound(self.value+wrap(n))
        return self.value - old
      end
  
      def lose(n = :all)
        -self.gain(-wrap(n))
      end
    end
  end
end
