class Array
  def random
    self[rand(self.length)]
  end
end

class Hash
  def random
    self.values.random
  end
end

class Range
  def random
    self.first + rand(self.last + 1 - self.first)
  end
end

module Random
  module Tracing
    $rand_trace = []
    def rand(*args)
      v = Kernel.rand(*args)
      $rand_trace << v
      v
    end

    at_exit {
      p $rand_trace
    }
  end
end
#include Random::Tracing
