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
  
  def to_s
    '[' + join(" ") + ']'
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

def deep_copy(obj)
  Marshal::load(Marshal.dump(obj))
end

