module GSL
  class Resource
    module Set
      def set(n)
        if self.class.range.include?(n.size)
          @value = own(n).dup
        else
          raise 'resource out of range'
        end
      end
  
      def if_gain(n)
        possible = @value + wrap(n)
        if self.class.range.include?(possible.size)
          return possible
        else
          raise Insufficient.new(name, @value, n)
        end
      end

      def if_lose(n = :all)
        n = wrap(n)
        possible = @value - n
        if possible.size == @value.size - n.size && self.class.range.include?(possible.size)
          return possible
        else
          raise Insufficient.new(name, @value, n)
        end
      end
      
      def must_gain(n)
        super(own(n))
      end
      
      def must_lose(n)
        super(forfeit(n))
      end
  
      def gain(n)
        possible = @value + own(n)
        @value = possible[0..(self.class.range.last-1)]
      end
  
      def lose(n = :all)
        n = forfeit(n)
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
      
      def wrap(n)
        n = super(n)
        if !n.kind_of? Array
          [n]
        else
          n
        end
      end
      
      def own(n)
        n = wrap(n)
        if (n && n.first.respond_to?(:in))
          n.each {|c| c.in = self; c.discard_to(discards)}
        else
          n
        end
      end
      
      def forfeit(n)
        n = wrap(n)
        if (n && n.first.respond_to?(:in))
          n.each {|c| c.in = nil}
        else
          n
        end
      end
      
      def discards
        if @discards.nil?
          @discards =
            self.class.option[:discard_to] ||
            (name.to_s + '_discard').to_sym
          if !@owner.respond_to?(@discards)
            @owner.class.make_resource(@discards)
            @owner.set_to [], @discards #type as set
          end
        end
        @owner.__send__(@discards)
      end
  
      def shuffle
        @value.shuffle!
      end

      def reshuffle
        gain(discards.lose(:all))
        @value.shuffle!
      end
  
      def primitive_draw
        card = @value.shift
        if (card.respond_to? :discard_to)
          card.discard_to discards
          card.in = nil
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
          card.discard_to discards
        end
        card
      end
  
      def sort_by!(&proc)
        @value = @value.sort_by(&proc) if @value
        return self
      end
      
      def include?(card)
        if card.kind_of?(Symbol) && @value.first.respond_to?(:name)
          return @value.find{|c| c.name == card}
        else
          return @value.include? card
        end
      end

      def without(item)
        #p "without #{item.to_s}"
        @value.delete item
        result = yield item
        @value << item
        return result
      end
  
      def to_s
        @value ||= []
        "#{name}:#{@value.count}/#{discards.count}(#{@value.count + discards.count})"
      end
  
      def to_a
        [@value.to_s, discards.to_s]
      end
    end
  end
end
