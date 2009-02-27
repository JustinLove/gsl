require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{random resource_user player_common future}

module GSL
  class Player
    include ResourceUser
    include Player::Common
    extend Yggdrasil::Citizen::Class
  
    def forward_to; @game; end
  
    attr_reader :color
    ygg_property :tiebreaker
  
    @@any_time = [NoAction.new]
  
    def self.at_any_time(name, proc)
      define_method(name, proc)
      @@any_time << name
    end
  
    def initialize(game)
      @world = game.world
      super()
      @game = game
      @w[:score] = 0
      @w[:tiebreaker] = 0
    end
    
    def pick_color(*choices)
      @color = (choices - @game.players.map {|pl| pl.color}).random
    end

    def take(from, &doing)
      best = best_rated(choose_from_what(from), &doing).switch
      note "take #{best.what} from #{from}"
      must_lose [best.what], from if best.legal?
      return best.what
    end
    
    def use(card, from = nil)
      if card.kind_of?(Symbol) && from
        card = from.find{|c| c.name == card}
        return use(card)
      end
      if (card)
        note "#{self.to_s} plays #{card.to_s}"
        execute card
        discard card
        true
      else
        false
      end
    end
  
    def discard(card)
      card.discard if (card.respond_to? :discard)
    end
  
    def each_player_from_left(&proc)
      @game.each_player :left_of => self, &proc
    end
  
    def other_players(&proc)
      @game.each_player :except => self, &proc
    end
    
    def pass; @w[:passed] = true; end

    def take_turn(&proc)
      passed = @w[:passed]
      @w[:passed] = false
      instance_eval(&proc)
      cont = !@w[:passed]
      @w[:passed] = passed
      return cont
    end
    
    def score(arg = nil, &proc)
      if block_given?
        @w[:score] = 0 unless arg == :keep
        f = Future.new(self, proc, 'score')
        @w[:score] = f.state[@w.id_card(:score)]
      elsif arg == :reset
        @w[:score] = 0
      elsif arg.kind_of?(Numeric)
        @w[:score] += arg
      else
        @w[:score]
      end
    end
    
    def plus(n)
      @w[:score] += n
    end
    
    def minus(n)
      @w[:score] -= n
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
