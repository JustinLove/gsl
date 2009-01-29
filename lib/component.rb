require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{world}

module GSL
  class Component
    extend World::Citizen::Class
    attr_reader :name

    class << self
      def hash(name, value)
        list = []
        value.each do|k,v|
          v.times {list << Component.new(k, name)}
        end
        list
      end

      def array(name, value)
        value.map {|v| Component.new(v, name)}
      end

      def fixnum(name, value)
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
      "#{@name}(#{@world && self.in})"
    end
    
    ver_reader :in
    def in=(where)
      if (@home.nil? && where.respond_to?(:discards))
        @home = where.discards
      end
      @w.world = @world = where.world if (where)
      @w[:in] = where
    end

    def discard(deck = nil)
      deck ||= @home
      if deck.include? self
        Langauge.error "attempt to discard #{self.to_s} twice"
      end
      self.in.lose [self] if self.in
      deck.gain [self]
    end

    def to_proc
      @@actions[self.name]
    end
  end
end
