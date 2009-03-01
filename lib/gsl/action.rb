module GSL
  class Action < Proc
    attr_reader :name
    
    def initialize(_name = "?", &block)
      super(&block)
      @name = _name
    end
    
    def to_s
      "Action #{name}"
    end
  end
  
  class NoAction
    def call; end
    def call_on(it, *args); end
    def to_proc; self; end
    def nil?; true; end
    def to_s
      "No Action"
    end
  end
end

class Proc
  def call_on(it, *args)
    it.instance_exec(*args, &self)
  end
end
