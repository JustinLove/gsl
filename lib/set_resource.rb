module GSL
  class Resource
    module Set
      def set(n)
        if self.class.range.include?(n.size)
          self.value = own(n).dup
        else
          raise 'resource out of range'
        end
      end
  
      def if_gain(n)
        possible = self.value + wrap(n)
        if self.class.range.include?(possible.size)
          return possible
        else
          raise Insufficient.new(name, self.value, n)
        end
      end

      def if_lose(n = :all)
        n = wrap(n)
        possible = self.value - n
        if possible.size == self.value.size - n.size && self.class.range.include?(possible.size)
          return possible
        else
          raise Insufficient.new(name, self.value, n)
        end
      end
      
      def must_gain(n)
        super(own(n))
      end
      
      def must_lose(n)
        super(forfeit(n))
      end
  
      def gain(n)
        possible = self.value + own(n)
        self.value = possible[0..(self.class.range.last-1)]
      end
  
      def lose(n = :all)
        n = forfeit(n)
        possible = self.value - n
        miss = self.class.range.first - possible.size
        old = self.value
        if (miss > 0)
          self.value = possible + n[0..miss]
        else
          self.value = possible
        end
        return old - self.value
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
        if (n && n.first.respond_to?(:in=))
          n.each {|c| c.in = self}
        else
          n
        end
      end
      
      def forfeit(n)
        n = wrap(n)
        if (n && n.first.respond_to?(:in=))
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
          end
          if !@owner.__send__(@discards).kind_of?(GSL::Resource::Set)
            @owner.set_to [], @discards #type as set
          end
        end
        @owner.__send__(@discards)
      end
  
      def shuffle
        self.value.shuffle!
      end

      def reshuffle
        gain(discards.lose(:all))
        self.value.shuffle!
      end
  
      def primitive_draw
        card = self.value.shift
        if (card.respond_to? :in=)
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
  
      def sort_by!(&proc)
        self.value = self.value.sort_by(&proc) if self.value
        return self
      end
      
      def include?(card)
        if card.kind_of?(Symbol) && self.value.first.respond_to?(:name)
          return self.value.find{|c| c.name == card}
        else
          return self.value.include? card
        end
      end

      def without(item)
        #p "without #{item.to_s}"
        self.value.delete item
        result = yield item
        self.value << item
        return result
      end
      
      def names
        self.value.map {|c| c.name}
      end
  
      def to_s
        self.value ||= []
        "#{name}:#{self.value.count}/#{discards.count}(#{self.value.count + discards.count})"
      end
  
      def to_a
        [self.value.to_s, discards.to_s]
      end
    end
  end
end
