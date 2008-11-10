module GSL
  module Set_Resource
    def set(n)
      if self.class.range.include?(n.size)
        @value = n
      else
        raise 'resource out of range'
      end
    end
  
    def if_gain(n)
      possible = @value + n
      if self.class.range.include?(possible.size)
        return possible
      else
        raise InsufficientResources.new(@name, @value, n)
      end
    end

    def if_lose(n = :all)
      if (n == :all)
        n = @value
      end
      possible = @value - n
      if @value.include?(n) && self.class.range.include?(possible.size)
        return possible
      else
        raise InsufficientResources.new(@name, @value, n)
      end
    end
  
    def gain(n)
      possible = @value + n
      @value = possible[0..(self.class.range.last-1)]
    end
  
    def lose(n = :all)
      n = @value if n == :all
      if !n.kind_of? Array
        n = [n]
      end
      possible = @value - n
      miss = self.class.range.first - possible.size
      old = @value
      if (miss > 0)
        @value = possible + n[0..miss]
      else
        @value = possible
      end
      return old - @value
    end
  
    def discard(card)
      @discards ||= []
      @discards << card
    end

    def shuffle
      @value.shuffle!
    end

    def reshuffle
      @value.concat @discards || []
      @discards = []
      @value.shuffle!
    end
  
    def primitive_draw
      card = @value.shift
      if (card.respond_to? :discard_to)
        card.discard_to self
      end
      card
    end
  
    def draw(&filter)
      @filter = filter || @filter
      if @filter
        @filter.call primitive_draw
      else
        primitive_draw
      end
    end
  
    def first
      card = @value.first
      if (card.respond_to? :discard_to)
        card.discard_to self
      end
      card
    end
  
    def sort_by!(&proc)
      @value = @value.sort_by(&proc) if @value
      return self
    end
  
    def to_s
      "#{name}:#{@value.count}/#{@discards.count}(#{@value.count + @discards.count})"
    end
  
    def to_a
      [@value.to_s, @discards.to_s]
    end
  end
end
