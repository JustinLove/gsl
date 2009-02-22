require File.join(File.expand_path(File.dirname(__FILE__)), 'state')

module Yggdrasil
  class World
    attr_reader :state
    attr_reader :reality
    
    def initialize
      super
      @state = @reality = State.new
    end
    
    def to_s
      "World (#{@state}, +#{@state.depth - @reality.depth})"
    end
    
    def inspect
      "World (s:#{@state}, r:#{@reality})"
    end
    
    def pretty_print(pp = nil)
      if (pp)
        super
      else
        @state.pretty_print
      end
    end
    
    def [](k)
      @state[k]
    end
    
    def []=(k, v)
      @state[k] = v
    end
    
    def grow(_name = nil)
      @state = @state.derive(_name) #.tap {|s| puts "#{@state} + #{s}"}
    end
    
    def prune
      raise "Can't prune past reality" if @state == @reality
      #puts "#{@state} - #{@state.parent}"
      @state = @state.parent
    end
    
    alias_method :begin, :grow
    alias_method :abort, :prune
    
    def commit
      raise "Can't commit past reality" if @state == @reality
      if (@state.parent == @reality)
        @reality = @state = @state.merge
      else
        @state = @state.merge
      end
    end
    
    def checkpoint(_name = nil)
      @reality = grow(_name)
    end
    
    def branch(_name = nil, &proc)
      enter(@state.derive(_name), &proc)
    end
    
    def enter(_state)
      hidden = [@state, @reality]
      @state = _state
      yield
      b = @state
      @state, @reality = hidden
      return b
    end
    
    def eval(_state)
      hidden = [@state, @reality]
      @state = _state
      r = yield
      @state, @reality = hidden
      return r
    end
    
    def switch(w)
      @reality = @state = w
    end
  end
end