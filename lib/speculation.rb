require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{misc}

module GSL
  class Speculation
    attr_reader :player
    attr_reader :action
    attr_reader :doing
    attr_reader :state
    attr_reader :text
    attr_accessor :rating
    
    def initialize(player, action, text = '?', &doing)
      super()
      @player = player
      @action = action
      @doing = doing
      s = action.to_s
      if (s[0,1] == '#')
        @text = text
      else
        @text = "#{text} #{s}"
      end
      @state = branch
    end
    
    def to_s
      "Speculation on #{@text}"
    end
    
    alias_method :[], :__send__
  
    def d(s)
      #puts "#{'.' * @@level} #{@player} #{@text}: " + s
    end
    
    def branch
      @player.world.branch do
        @player.world[:legal] = go #.tap {|v| p v}
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
        @player.world[:speculate_on] = ('.' * @@level) # + @text
        d 'block ' # takes forever + @action.inspect
        @player.execute(@action, &@doing)
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
