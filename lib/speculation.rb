require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{misc}

module GSL
  class Speculation
    attr_reader :who
    attr_reader :what
    attr_reader :how
    attr_reader :state
    attr_reader :why
    attr_accessor :rating
    
    def initialize(who, what, why = '?', &how)
      super()
      @who = who
      @what = what
      @how = how
      s = what.to_s
      if (s[0,1] == '#')
        @why = why
      else
        @why = "#{why} #{s}"
      end
      @state = branch
    end
    
    def to_s
      "Speculation on #{@why}"
    end
    
    def d(s)
      #puts "#{'.' * @@level} #{@who} #{@why}: " + s
    end
    
    def branch
      @who.world.branch do
        @who.world[:legal] = go #.tap {|v| p v}
      end
    end
  
    def legal?
      @state[:legal]
    end
    
    alias_method :legal, :legal?
  
    @@level = 0
    def go
      begin
        @@level += 1
        @who.world[:speculate_on] = ('.' * @@level) # + @why
        d 'block ' # takes forever + @what.inspect
        @who.execute(@what, &@how)
      rescue GamePlayException => e
        d e.inspect
        #puts e.backtrace.join("\n")
        return Passed
      rescue Exception => e
        raise e
      else
        d 'succeeded'
        return Acted
      ensure
        @@level -= 1
      end
    end
  end
end
