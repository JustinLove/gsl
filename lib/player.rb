module GSL
  class Player
    include Prototype
    extend Prototype
    include ResourceUser
  
    def forward_to; @game; end
    def speculator; self; end
  
    module Common
      def execute(action)
        instance_eval(&(action.to_proc))
      end
    
      def what_if(on = '?', &proc)
        Speculate.new(speculator, on).go(&proc) #.tap {|v| p v}
      end
    
      def rate(action)
        if (action.respond_to? :to_proc)
          good = what_if("rates #{action.to_s}") {execute action}
          if good then 1 else 0 end
        else
          0
        end
      end
    
      def judge(action)
        if rate(action) > 0 then :good else :bad end
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
  
    def choose_best(from, actions = nil)
      choices = __send__(from)
      choices.sort_by! {|c| -rate(c)}
      if (choices.first != Empty && !actions.nil?)
        kind = judge(choices.first)
        if (actions[kind].call(choices.first) == Acted)
          choices.draw
        else
          Empty
        end
      else
        choices.draw
      end
    end
  
    def use(card, from = nil)
      if card.kind_of?(Symbol) && from
        card = from.find{|c| c.name == card}
        return use(lose(card, from.name).first)
      end
      if (card)
        puts "#{self.to_s} plays #{card.to_s}" 
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
  
    def to_s
      @color.to_s
    end
  
  end
end