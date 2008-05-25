class Prototype
  def method_missing(which, *args, &block)
    p "missing #{self.class}.#{which}" + args.inspect + block.inspect
  end
end

class Game < Prototype
  attr_reader :name
  attr_reader :players
  attr_reader :components
  attr_reader :board
  
  def initialize(name)
    @name = name
  end
  
  def for_players(range)
    @players = range
  end
  
  def has_components()
    @components = Componenets.new
    yield(@components)
  end
  
  def has_board()
    @board = Board.new
    yield(@board)
  end
  
  def has_rounds(n)
    @rounds = n
  end
  
  def every_round()
    @aRound = Round.new
    yield(@aRound)
  end
  
  def play()
    game_setup()
    @rounds.times do |n|
      @aRound.play
    end
  end
end

class Round < Prototype
  def initialize()
    @phases = Hash.new
  end
  
  def phase_order(order)
    @the_order = order
  end
  
  def play()
    @the_order.each do |phase|
      self.__send__(phase)
    end
  end
  
  def method_missing(method, *args, &block)
    #p "Round.method_missing" + method.to_s + @phases.inspect
    if find = method.to_s.match(/^to_(\w+)$/)
      @phases[find[1].to_sym] = block
    elsif @phases.include? method
      #p 'found'
      @phases[method].call(*args)
    else
      super
    end
  end
end

class Component
  attr_reader :symbol
  attr_reader :description
  
  def initialize(sym, description)
    @symbol = sym
    @description = description
  end

  def has(hash)
    hash.each {|k,v| instance_variable_set("@#{k}", v)}
    hash.each {|k,v| self.class.__send__(:attr_reader, k)}
  end
end

class Componenets
  attr_reader :list
  
  def initialize()
    @list = Hash.new
  end
  
  def has(count, sym, description)
    @list[sym] = Array.new(count)
    #p 'define', sym, @list[sym]
    count.times {|i| @list[sym][i] = Component.new(sym, description) }
  end
  
  def players_have(count, sym, description)
    has(count, sym, description)
  end

  def custom(which)
    yield(@list[which])
  end
  
  def assign_random(which, set)
    from = @list[which]
    #p which.inspect + set.inspect
    set.each_index do |i|
      set[i] = from[rand(from.length)]
    end
    puts set
  end
end

class Board
  def has(hash)
    hash.each {|k,v| instance_variable_set("@#{k}", v)}
    hash.each {|k,v| self.class.__send__(:attr_reader, k)}
  end
end

def rules_for(name)
  game = Game.new(name)
  yield(game)
  return game
end

roman = rules_for "Gregs Roman Game" do |game|
  game.for_players 3..5
  
  game.has_components do |list|
    list.has 50, :gold, "yellow cube"
    list.has 50, :person, "white cube"
    list.has 20, :senator, "custom tile"
    list.has 16, :privlige, "custom tile"
    list.has 20, :gate, "tile"
    list.has 20, :farm, "tile"
    list.has 20, :mine, "tile"
    list.has 10, :dock, "tile"
    list.has 10, :colusemum, "tile"
    list.has 10, :forum, "tile"
    list.has 10, :market, "tile"
    list.has 10, :monument, "tile"
    list.has 10, :expansion, "tile"
    list.has 10, :temple, "tile"
    list.players_have 1, :pawn, "pawn"
    list.players_have 1, :score, "cube"
    
    senators_give = [:gate, :farm, :mine, :special, :expansion, :temple, :monument]
    
    list.custom :senator do |senators|
      senators.each do |s|
        s.has :gold => rand(4)+1
        s.has :people => rand(4)+1
        s.has :influence => s.gold + s.people - 1
        s.has :gives => senators_give[rand(senators_give.length)]
        def s.to_s 
          "#{@people},#{@gold} => #{@influence},#{@gives}" 
        end
      end
    end
    
    list.custom :privlige do |privs|
      privs[0,2] = "Double Buy"
      privs[2,2] = "Move Back"
      privs[4,2] = "Extra gold"
      privs[6,2] = "Extra People"
      
      privs[8,2] = "Don't pay gold"
      privs[10,2] = "Double Special"
      privs[12,2] = "Speical 1"
      privs[14,2] = "Special 2"
    end
  end
  
  game.has_board do |layout|
    layout.has :senate => [
      Array.new(2),
      Array.new(5),
      Array.new(6),
      Array.new(7)
    ]
    layout.has :turn_order => Array.new(game.players.max)
  end
  
  game.game_setup do |setup|
    
  end
  
  game.has_rounds 4

  game.every_round do |round|
    round.phase_order [:setup, :execute, :finish]
    round.to_setup do
      game.board.senate.each do |row|
        game.components.assign_random(:senator, row)
      end
    end
    round.to_execute do
    end
    round.to_finish do
    end
  end
  
  game.players_can do |player|
    
  end
end

roman.play();