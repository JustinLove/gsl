require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{random prototype resource_user player_common speculate}

module GSL
  class Player
    include Prototype
    extend Prototype
    include ResourceUser
    include Player::Common
  
    def forward_to; @game; end
  
    attr_reader :color
  
    @@any_time = []
  
    def self.at_any_time(action, proc)
      define_method(action, proc)
      @@any_time << action
    end
  
    def initialize(game)
      @world = game.world
      super()
      @game = game
    end
    
    def pick_color(*choices)
      @color = (choices - @game.players.map {|pl| pl.color}).random
    end

    def take(from, &doing)
      best = best_rated(choose_from_what(from), &doing)
      if (best)
        note "take #{best.to_s} from #{from}"
        must_lose [best[:action]], from
        return execute best[:action], &doing
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
          puts "USE FAILED #{card}"
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
      puts(@world[:speculate_on].to_s + what) if (!@world[:speculate_on])
    end
  
    def to_s
      if @color
        @color.to_s
      else
        super
      end
    end
  
  end
end
