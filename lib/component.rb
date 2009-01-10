require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{prototype}

module GSL
  class Component
    include Prototype
    extend Prototype
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
     
    attr_accessor :in
     
    def initialize(name, kind = nil)
      @name = name
      @kind = kind || name
      @in = nil
    end

    def to_s
      "#{@name}(#{@in})"
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
      @in.lose [self] if @in
      deck.gain [self]
    end

    def to_proc
      @@actions[self.name]
    end
  end
end
