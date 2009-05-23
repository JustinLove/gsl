require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{ygg}

module GSL
  class Component
    extend Yggdrasil::Citizen::Class
    attr_reader :name

    class << self
      def from(name, value)
        self.__send__("from"+value.class.name, name, value)
      end
      
      def fromHash(name, value)
        list = []
        value.keys.sort_by{|k| k.to_s}.each do|k|
          value[k].times {list << Component.new(k, name)}
        end
        list
      end

      def fromArray(name, value)
        value.map {|v| Component.new(v, name)}
      end

      def fromFixnum(name, value)
        list = []
        value.times {list << Component.new(name)}
        list
      end

      @@actions = {}
      def define_action(name, proc)
        @@actions[name] = proc
      end
    end
     
    def initialize(name, kind = nil)
      super()
      @world = nil
      @name = name
      @kind = kind || name
      @home = nil
    end

    def to_s
      name.to_s
    end
    
    def inspect
      "#{@name}(#{@world && self.in})"
    end
    
    ygg_reader :in
    def in=(where)
      if (@home.nil? && where.respond_to?(:discards))
        @home = where.discards
      end
      self.world = where.world if (where)
      @w[:in] = where
    end

    def discard(deck = nil)
      deck ||= @home
      if deck.include? self
        Language.error "attempt to discard #{self.to_s} twice"
      end
      self.in.lose [self] if self.in
      deck.gain [self]
    end

    def to_proc
      @@actions[self.name]
    end
  end
end
