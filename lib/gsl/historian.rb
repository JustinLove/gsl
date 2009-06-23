module GSL
  class Historian
    def to_s
      "History:"
    end
    
    def record(what)
      case (what)
      when Resource; record_resource(what);
      else; raise "Can't record #{what.class}"
      end
    end
    
    def record_resource(what)
      p what.value
    end
  end
end
