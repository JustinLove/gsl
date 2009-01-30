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
      "#{self.class} on #{@why}"
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
    
    def switch_if_legal
      if legal?
        switch
        yield(self) if block_given?
      else
        @who.note " * can't because #{@why_failed}" if @who
        self
      end
    end
    
    def switch
      @who.world.switch(@state)
    end
    
    @@level = 0
    def go
      begin
        @@level += 1
        @who.world[:speculate_on] = ('.' * @@level) # + @why
        d "#{@who} #{why}", ""
        execute
      rescue Game::Illegal => e
        d @why_failed = e
        @who.note " * can't because #{@why_failed}" if @who
        #puts e.backtrace.join("\n")
        return false
      rescue Exception => e
        raise e
      else
        #d 'succeeded'
        return true
      ensure
        @@level -= 1
        @who.world[:speculate_on] = ('.' * @@level)
      end
    end
    
    def execute
      #d "exec #{@what} #{@how}"
      if @how
        @who.instance_exec(@what, &@how)
      elsif (@what && @what.respond_to?(:to_proc))
        @who.instance_exec(&(@what.to_proc))
      else
        Language.error "nothing executable"
      end
    end
    
    class Nil < Speculation
      def initialize()
        @who = nil
        @what = nil
        @how = nil
        @why = nil
      end
      def branch; nil; end
      def legal?; false; end
      def nil?; true; end
    end
  end
  
end
