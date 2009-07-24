module GSL
  class Historian
    class Event
      def initialize(_historian, starting = {})
        @historian = _historian
        @data = starting
        super()
      end
      
      def to_s
        "Event: " + @data.to_s
      end
      
      def record(what)
        case (what)
        when Resource; record_resource(what);
        else; raise "Can't record #{what.class}"
        end
      end
    
      def record_resource(what)
        @data[what.name] = what.value
      end
      
      def [](k)
        return @data[k]
      end
    end
    
    def to_s
      "History:"
    end
    
    def event(starting = {})
      Event.new(self, starting)
    end
  end
end
