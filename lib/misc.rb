Infinity = 2**30

Empty = nil

class Array
  def rotate
    self.push self.shift
  end

  def to_s
    '[' + (map {|i| i.to_s}).join(" ") + ']'
  end
end

class Range
  def bound(n)
    if (n < self.first)
      return self.first
    elsif (n > self.last)
      return self.last
    else
      return n
    end
  end
end

class Fixnum
  def piles
    Array.new(self) {[]}
  end
end

class Proc #:nodoc:
  def bind(object)
    block, time = self, Time.now
    (class << object; self end).class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end

class Object
  unless defined? instance_exec # 1.9
    def instance_exec(*arguments, &block)
      block.bind(self)[*arguments]
    end
  end
  
  def primitive?
    begin
      self.dup
      false
    rescue TypeError
      true
    end
  end
end

def deep_copy(obj)
  Marshal::load(Marshal.dump(obj))
end

module GSL
  module Raiser
    def self.named(name)
      Module.new do
        include Raiser
        alias_method name, :raiser
        public name
      end
    end

    private
    def raiser(error, *args)
      case error.class.to_s.to_sym
      when :Symbol
        raise self.const_get(error), *args
      when :String
        raise @default_exception, error, *args
      else
        raise error, *args
      end
    end
  end

  class Game
    extend Raiser.named(:illegal)
    
    class Illegal < Exception 
    end
    @default_exception = Illegal
  
    class FailedPrecondition < Illegal
    end

    class NotAllowed < Illegal
    end
  end
  
  module Language
    extend Raiser.named(:error)

    class Error < Exception
    end
    @default_exception = Error
  end
end
