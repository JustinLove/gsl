require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{prototype world}

module GSL
  class Component
    include Prototype
    extend Prototype
    extend World::Citizen::Class
    attr_reader :name
    attr_accessor :in
    attr_writer :world

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
      self.in = nil
    end

    def to_s
      "#{@name}(#{self.in})"
    end

    def discard_to(where)
      if (@home.nil?)
        @home = where
      end
      return self
    end

    def discard(deck = nil)
      deck ||= @home
      if deck.include? self
        raise "attempt to discard #{self.to_s} twice"
      end
      self.in.lose [self] if self.in
      deck.gain [self]
    end

    def to_proc
      @@actions[self.name]
    end
  end
end
