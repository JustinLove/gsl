require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{misc}

module GSL
  class Future
    attr_reader :who
    attr_reader :what
    attr_reader :how
    attr_reader :why
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
      @state = nil
    end
    
    def to_s
      "#{self.class}#{if (deferred?) then '*' else '' end} on #{@why} (#{@rating})"
    end
    
    def inspect
      "#{self.class}#{if (deferred?) then '*' else '' end}, " +
      "#{(@who.respond_to?(:name) && @who.name) || @who.object_id} " +
      "on #{@why}(#{describe_action}) -> #{@rating}/#{@state && @why_failed}"
    end
    
    def d(s, indent = "- ")
      #puts "#{' ' * @@level}#{indent}" + s.to_s
    end
    
    def state
      @state ||= branch
    end
    
    def why_failed
      force; @why_failed
    end
    
    def force
      state
    end
    
    def deferred?
      @state == nil
    end
    
    def branch
      @who.world.branch(@why) do
        @who.world[:chooser] = @who.to_s
        @who.world[:choice] = describe_action
        propigate_errors(go)
      end
    end
    
    def propigate_errors(legal)
      @who.world.state.update(:legal, true) {|old| legal && old}
    end
  
    def legal?
      state[:legal]
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
      @who.world.switch(state) unless @who.nil?
      self
    end
    
    @@level = 0
    def go
      begin
        @@level += 1
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
      end
    end
    
    def execute
      #d "exec " + describe_action
      if @how
        @who.instance_exec(@what, &@how)
      elsif (@what && @what.respond_to?(:to_proc))
        @who.instance_exec(&(@what.to_proc))
      else
        Language.error "nothing executable"
      end
    end
    
    def get_location(proc)
      s = proc.to_s
      m = s.match(/@(\/.*\/)?([^\/]+:\d+)/)
      (m && m[2]) || s      
    end
    
    def describe_action
      if @how
        get_location(@how) + "(#{@what.to_key})"
      elsif (@what && @what.respond_to?(:to_proc))
        get_location(@what)
      else
        Language.error "nothing executable"
      end
    end
    
    class Nil < Future
      def initialize()
        @who = nil
        @what = nil
        @how = nil
        @why = nil
      end
      def branch; nil; end
      def legal?; false; end
      def nil?; true; end
      def describe_action; 'Nil'; end
    end
  end
  
end
