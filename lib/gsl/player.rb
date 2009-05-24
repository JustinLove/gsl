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
    ygg_reader :absolute_fitness
  
    @@free_actions = [NoAction.new]
  
    def self.at_any_time(name, proc)
      define_method(name, proc)
      @@free_actions << Action.new(name, &proc)
    end
    
    def free_actions
      @@free_actions
    end
    
    def with_free_actions
      choose free_actions do |act|
        execute act
        yield
      end
    end

    psuedo_class_var :hints
    cv.hints = []
    def self.hint(&proc)
      cv.hints << proc
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
        @w[:score] = f.state[@w.rune(:score)]
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
