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
  attr_reader :desiger
  attr_reader :player_range
  attr_reader :players
  attr_reader :components
  attr_reader :board
  
  def initialize(name, designer = "")
    @name = name
    @designer = designer
  end
  
  def for_players(range)
    @player_range = range
  end
  
  def contents()
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
  def initialize(r, has = 0, req = 0)
    @resource = r
    @has = has
    @req = req
  end
  
  def to_s
    "Insufficient #{@resource}, #{@has} < #{@req}"
  end
end

class Player < Prototype
  attr_reader :name
  attr_accessor :done
  
  @@actions = {}
  @@action_order = []
  @@resources = {}
  @@player_values = {}
  
  def self.has(resource, example = 0)
    @@resources[resource] = example;
  end
  
  def self.values(resource, modifier)
    @@player_values[resource] = modifier
  end
  
  def self.can(action, &block)
    @@actions[action] = block
    @@action_order << action
  end
  
  def initialize(named)
    @name = named
    @done = false
    @resources = {}
    @@resources.each do |k,v|
      if (v.class == Array)
        vn = v.dup
      else
        vn = v
      end
      has(k,vn)
    end
  end
  
  def has(resource, value)
    @resources[resource] = value
  end
  
  def take_turn()
    for a in @@action_order
      v = @@actions[a].call(self)
      #p a, v
      if (v)
        p "#{@name} #{a}"
        break
      end
    end
  end

  def spend_check(resource, how_much)
    if (how_much.class == Array)
      if (!@resources[resource].include? how_much)
        raise InsufficientResources.new(resource)
      end
    elsif (@resources[resource] < how_much)
      raise InsufficientResources.new(resource, @resources[resource], how_much)
    end
  end
  
  def can_spend(resource, how_much)
    begin
      spend_check(resource, how_much)
      #puts "#{resource} okay"
      return true
    rescue InsufficientResources
      #puts "#{resource} xxxxx`"
      return false
    end
  end
  
  def spend(resource, how_much)
    spend_check(resource, how_much)
    #puts "#{resource} - #{how_much}"
    @resources[resource] -= how_much
  end
  
  def gain(resource, how_much)
    @resources[resource] += how_much
  end

  def valuate_resource(resource, how_much)
    if (how_much.kind_of? Enumerable)
      return how_much.inject(0) {|a, x| a + valuate_resource(resource, x)}
    elsif (how_much.kind_of? Numeric)
      return value_modifier(resource) * how_much
    else
      return value_modifier(resource) * value_modifier(how_much)
    end
  end
  
  def value_modifier(what)
    if (@@player_values.include? what)
      return @@player_values[what]
    else
      return 1
    end
  end
  
  def reset(resource, to)
    @resources[resource] = to
  end
  
  def count_in(resource, what)
    @resources[resource].find_all {|r| r == what}.length
  end
  
  def method_missing(method, arg1 = nil)
    #p method, arg1
    by = method.to_s + '_by'
    if (arg1.respond_to?(by))
      arg1.__send__(by, self)
    elsif (@resources.keys.include? method)
      @resources[method]
    else
      super
    end
  end
  
  def to_s
    @name + ": " + @resources.inspect
  end
  
end

class Component
  attr_reader :symbol
  attr_reader :description
  
  def initialize(sym, description)
    @symbol = sym
    @description = description
    @costs = []
    @benefits = []
  end

  def has(hash)
    hash.each {|k,v| instance_variable_set("@#{k}", v)}
    hash.each {|k,v| self.class.__send__(:attr_reader, k)}
  end
  
  def cost(hash)
    hash.each {|k,v| @costs << k}
    has hash
  end
  
  def benefit(hash)
    hash.each {|k,v| @benefits << k}
    has hash
  end
  
  def purchase_by(player)
    @costs.each {|k| player.spend k, instance_variable_get("@#{k}")}
    @benefits.each {|k| player.gain k, instance_variable_get("@#{k}")}
  end
  
  def afford_by(player)
    @costs.all? {|k| player.can_spend(k, instance_variable_get("@#{k}"))}
  end
  
  def valuate_by(player)
    @costs.inject(0) {|n,k| n - player.valuate_resource(k, instance_variable_get("@#{k}"))} +
      @benefits.inject(0) {|n,k| n + player.valuate_resource(k, instance_variable_get("@#{k}"))}
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
  
  def all(area)
    instance_variable_get("@#{area}").flatten.compact
  end
  
  def choose_from(area)
    all(area).random
  end
  
  def remove(area, what)
    from = instance_variable_get("@#{area}")
    remove_one(from, what)
  end
end

def rules_for(name)
  game = Game.new(name)
  yield(game)
  return game
end

