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
      }.sort_by {|r| r.rating}
    end

    def rate(what, why = 'rates')
      s = Future.new(@who, what, why, &@how)
      s.rating = @who.rate_state(s.state)
      s
    end
    
    def best
      best = @what.last || Future::Nil.new
      unless (best.nil? || best.legal?)
        Game.illegal(:NoLegalOptions, @what.map{|c| c.why}.join(', '))
      end
      best
    end
  end
end