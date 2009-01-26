require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{misc}

module GSL
  class Speculation
    attr_reader :player
    attr_reader :action
    attr_reader :state
    attr_reader :text
    attr_accessor :rating
    
    def initialize(player, action, text = '?')
      super()
      @player = player
      @action = action
      @text = text
      @state = branch
    end
    
    def to_s
      "Speculation on #{@text}"
    end
  
    def d(s)
      #puts "#{'.' * @@level} #{@player} #{@text}: " + s
    end
    
    def branch
      @player.world.branch do
        @player.world[:legal] = go(&@action) #.tap {|v| p v}
      end
    end
  
    def succeed?
      branch[:legal]
    end
  
    @@level = 0
    def go
      begin
        @@level += 1
        @player.world[:speculate_on] = ('.' * @@level) # + @text
        d 'block ' + @action.inspect
        @player.instance_eval &@action
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
