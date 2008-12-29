Infinity = 2**30

def Error(*args); raise *args; end
Empty = nil
Acted = true
Passed = false
alias :Action :lambda

class Array
  def rotate
    self.push self.shift
  end
  
  def value
    return self
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
  
  def value
    return self
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
end

def deep_copy(obj)
  Marshal::load(Marshal.dump(obj))
end

module GSL
  class GamePlayException < Exception 
  end
  
  class FailedPrecondition < GamePlayException
  end

  class NotAllowed < GamePlayException
  end
end
