module GSL
  class Plan
    def initialize(_who, _what, &_how)
      super()
      @who = _who
      @what = _what
      @how = _how
      s = @what.to_s
      if (s[0,1] == '#')
        @why = "#{@what.class}"
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
  end
end