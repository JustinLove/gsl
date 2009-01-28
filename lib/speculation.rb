require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{misc}

module GSL
  class Speculation
    attr_reader :who
    attr_reader :what
    attr_reader :how
    attr_reader :state
    attr_reader :why
    attr_reader :why_failed
    attr_accessor :rating
    
    def initialize(who, what, why = '?', &how)
      super()
      @who = who
      @what = what
      @how = how
      s = what.to_s
      if (s[0,1] == '#')
        @why = "#{why} #{what.class}"
      else
        @why = "#{why} #{s}"
      end
      @state = branch
    end
    
    def to_s
      "Speculation on #{@why}"
    end
    
    def d(s, indent = "- ")
      #puts "#{' ' * @@level}#{indent}" + s
    end
    
    def branch
      @who.world.branch do
        @who.world[:legal] = go #.tap {|v| p v}
      end
    end
  
    def legal?
      @state[:legal]
    end
    
    @@level = 0
    def go
      begin
        @@level += 1
        @who.world[:speculate_on] = ('.' * @@level) # + @why
        d "#{@who} #{why}", ""
        @who.execute(@what, &@how)
      rescue GamePlayException => e
        d @why_failed = e
        #puts e.backtrace.join("\n")
        return Passed
      rescue Exception => e
        raise e
      else
        #d 'succeeded'
        return Acted
      ensure
        @@level -= 1
        @who.world[:speculate_on] = ('.' * @@level)
      end
    end
  end
end
