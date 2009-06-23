require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{ygg}

module GSL
  class Component
    extend Yggdrasil::Citizen::Class
    attr_reader :name

    class << self
      def from(name, value, world = nil)
        self.__send__("from"+value.class.name, name, value, world)
      end
      
      def fromHash(name, value, world = nil)
        list = []
        value.keys.sort_by{|k| k.to_s}.each do|k|
          value[k].times {list << Component.new(k, name, world)}
        end
        list
      end

      def fromArray(name, value, world = nil)
        value.map {|v| Component.new(v, name, world)}
      end

      def fromFixnum(name, value, world = nil)
        list = []
        value.times {list << Component.new(name, name, world)}
        list
      end

      @@actions = {}
      def define_action(name, proc)
        @@actions[name] = proc
      end
    end
     
    def initialize(name, kind = nil, _world = nil)
      super()
      @name = name
      @kind = kind || name
      self.world = _world
      @home = nil
    end
    
    def dup(_world = nil)
      self.class.new(@name, @kind, _world)
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
