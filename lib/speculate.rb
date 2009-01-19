require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')

module GSL
  class Speculate
    def initialize(player, on = '?')
      super()
      @player = player
      @on = on
    end
  
    def d(s)
      #puts "#{'.' * @@level} #{@player} #{@on}: " + s
    end
    
    def branch(&proc)
      @player.world.branch do
        go(&proc) #.tap {|v| p v}
      end
    end
  
    def succeed?(&proc)
      ret = nil
      @player.world.branch do
        ret = go(&proc) #.tap {|v| p v}
      end
      ret
    end
  
    @@level = 0
    def go(&proc)
      begin
        @@level += 1
        d 'block ' + proc.inspect
        @player.instance_eval &proc
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
