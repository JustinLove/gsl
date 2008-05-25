class Array
  def random
    self[rand(self.length)]
  end
end

class Hash
  def random
    self.values.random
  end
end

class Prototype
  def method_missing(which, *args, &block)
    p "missing #{self.class}.#{which}" + args.inspect + block.inspect
  end
end

class Game < Prototype
  attr_reader :name
  attr_reader :player_range
  attr_reader :players
  attr_reader :components
  attr_reader :board
  
  def initialize(name)
    @name = name
  end
  
  def for_players(range)
    @player_range = range
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
  
  def players_have()
    yield(Player)
  end
  
  alias :players_can :players_have
  
  def game_setup(&block)
    @setup = block
  end
  
  def play(number_of_players)
    @players = Array.new(4) {|i| Player.new("Player #{i}")}
    @setup.call()
    @rounds.times do |n|
      @aRound.play()
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

class InsufficientResources < RuntimeError
  attr :resource
  def initialize(r)
    @resource = r
  end
end

class Player < Prototype
  attr_reader :name
  
  @@actions = {}
  @@resources = []

  
  def self.has(resource)
    @@resources << resource
  end
  
  def self.can(action, &block)
    @@actions[action] = block
  end
  
  def initialize(named)
    @name = named
    @resources = {}
    @@resources.each {|r| has(r)}
  end

  def has(resource)
    @resources[resource] = 0
  end
  
  def take_turn()
    @@actions.random.call(self)
    p @name, @resources
  end
  
  def spend(resource, how_much)
    if (@resources[resource] < how_much)
      raise InsufficientResources.new(:resource)
    end
    @resources[resource] -= how_much
  end
  
  def gain(resource, how_much)
    @resources[resource] += how_much
  end
  
  def reset(resource, to)
    @resources[resource] = to
  end
  
  def collect(resource, what)
    if @resources[resource].class != Array
      @resources[resource] = []
    end
    @resources[resource] << what
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
    #puts set
  end
end

def remove_one(thingy, what)
  if (thingy[0].class == Array)
    thingy.each do |x| 
      remove_one(x, what) 
    end
  else
    thingy.each_index do |i|
      if thingy[i] == what
        thingy[i] = nil
        return
      end
    end
  end
end

class Board < Prototype
  def has(hash)
    hash.each {|k,v| instance_variable_set("@#{k}", v)}
    hash.each {|k,v| self.class.__send__(:attr_reader, k)}
  end
  
  def choose_from(area)
    instance_variable_get("@#{area}").flatten.compact.random
  end
  
  def remove(area, what)
    from = instance_variable_get("@#{area}")
    
  end
end

def rules_for(name)
  game = Game.new(name)
  yield(game)
  return game
end

