module GSL
  class Player
    include Prototype
    extend Prototype
    include ResourceUser
  
    def forward_to; @game; end
    def speculator; self; end
  
    module Common
      def choose(from, &doing)
        best = best_rated(choose_from_what(from), &doing)
        if (best)
          #note "choose #{best.to_s} from #{from}"
          return execute best, &doing
        else
          return best
        end
      end

      def choose_from_what(from)
        case from.class.to_s.to_sym
        when :Array:
          from
        when :Hash:
          from.values
        when :Symbol:
          __send__(from)
        else
          if (from.kind_of? Resource)
            from
          else
            throw "can't choose from a #{from.class}"
          end
        end
      end
      
      def best_rated(from, &doing)
        # concat: operate on a copy so changes don't mess us up
        [].concat(from).sort_by {|c| -rate(c, 'best', &doing)}.first
      end
      
      def execute(*args, &proc)
        if proc
          instance_exec(*args, &proc)
        elsif (args && args.first.respond_to?(:to_proc))
          action = args.shift
          instance_exec(*args, &(action.to_proc))
        else
          nil
        end
      end
    
      def what_if(on = '?', &proc)
        Speculate.new(speculator, on).go(&proc) #.tap {|v| p v}
      end
    
      def rate(action, why = 'rates', &doing)
        raise if !action
        if (action.respond_to? :in)
          action.in.without(action) {rate_action action, why, &doing}
        else
          rate_action(action, why, &doing)
        end
      end

      def rate_action(action, why = 'rates', &doing)
        good = what_if("#{why} #{action.to_s}") {execute action, &doing}
        if good then 1 else 0 end
      end

      def judge(action)
        if rate(action, 'judges') > 0 then :good else :bad end
      end
    
      def legal?(action)
        what_if("checks #{action.to_s}") {execute action}
      end
      
    end
    include Common
  
    attr_reader :color
  
    @@any_time = []
  
    def self.at_any_time(action, proc)
      define_method(action, proc)
      @@any_time << action
    end
  
    def initialize(game)
      @game = game
      resource_init
    end
    
    def method_missing(method, *args, &block)
      if @resources.keys.include? method
        #puts 'player ' + method.to_s
        return @resources[method]
      end
      if @game.resources.keys.include? method
        #puts 'game ' + method.to_s
        return @game.__send__(method, *args, &block)
      end
      if @game.respond_to? method
        return @game.__send__(method, *args, &block)
      end
      super
    end

    def pick_color(*choices)
      @color = (choices - @game.players.map {|pl| pl.color}).random
    end

    def take(from, &doing)
      best = best_rated(choose_from_what(from), &doing)
      if (best)
        note "take #{best.to_s} from #{from}"
        must_lose [best], from
        return execute best, &doing
      else
        return best
      end
    end
    
    def use(card, from = nil)
      if card.kind_of?(Symbol) && from
        card = from.find{|c| c.name == card}
        return use(card)
      end
      if (card)
        note "#{self.to_s} plays #{card.to_s}" 
        if (legal?(card))
          execute card
          discard card
          return Acted
        else
          p 'USE FAILED'
          return Passed
        end
      else
        Passed
      end
    end
  
    def discard(card)
      card.discard
    end
  
    def each_player_from_left(&proc)
      @game.each_player :left_of => self, &proc
    end
  
    def other_players(&proc)
      @game.each_player :except => self, &proc
    end
    
    def note(what)
      puts what
    end
  
    def to_s
      @color.to_s
    end
  
  end
end
