require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{future}

module GSL
  class Plan
    def initialize(_who, _what, &_how)
      super()
      @who = _who
      @how = _how
      @what = rate_choices(array_from(_what))
      s = @how.to_s
      if (s[0,1] == '#')
        @why = "#{@how.class}"
      else
        @why = "#{s}"
      end
    end
    
    def to_s
      "#{self.class} on #{@why}"
    end

    def inspect
      "#{self.class}, " +
      "#{(@who.respond_to?(:name) && @who.name) || @who.object_id} " +
      "on #{@why}"
    end
    
    def each(&block)
      @what.each(&block)
    end
    include Enumerable

    def array_from(from)
      case from
      when Array
        from
      when Hash
        from.values
      when Range
        from.to_a
      when Fixnum
        (0..from).to_a
      when Symbol
        @who.__send__(from)
      else
        if (from.kind_of? Resource)
          from
        else
          Language.error "can't choose from a #{from.class}"
        end
      end
    end
    
    def rate_choices(from)
      from.map {|c|
        rate(c)
      }
    end

    class Cached < Plan
      @@ratings = {}

      def rate(what, why = 'rates')
        s = Future.new(@who, what, why, &@how)
        s.rating = @@ratings[s.describe_action] ||= @who.rate_state(s.state)
        s
      end

      def best
        if (@what.empty?)
          return Future::Nil.new
        end
        @what.sort_by {|r| -r.rating}.each do |choice|
          if choice.legal?
            return choice
          end
        end
        Game.illegal(:NoLegalOptions, @what.map{|c| c.why}.join(', '))
      end
    end
  end
end