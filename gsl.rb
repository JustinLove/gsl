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

module Prototype
  def method_missing(which, *args, &block)
    puts "missing #{self.class}.#{which} #{args.inspect} {#{block.inspect}}"
  end
end

module Properties
  def as_property(named)
    define_method(named) do |value|
      instance_variable_set("@#{named}", value)
    end
  end
end

class Game
  include Prototype
  extend Properties

  as_property :title
  as_property :author
  as_property :players
  
  def initialize(file)
    self.instance_eval(File.read(file), file)
    puts self
  end
  
  def to_s
    "#{@title} by #{@author}, #{@players} players"
  end
end

class Round
  include Prototype
  
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

class Player
  include Prototype
  
  attr_reader :name
  attr_accessor :done
  attr_accessor :score
  
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
  
  def take_turn(which = nil)
    if (which)
      if (@@actions.keys.include? which)
        @@actions[which].call(self)
      else
        __send__(which) #trigger method missing
      end
    else
      for a in @@action_order
        v = @@actions[a].call(self)
        #p a, v
        if (v)
          p "#{@name} #{a}"
          break
        end
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
  
  alias :lose :spend
  
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
    elsif (@@actions and @@actions.keys.include? method)
      @@actions[method].call(self)
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
  
  def special(&proc)
    self.class.define_method @symbol, &proc
  end
  
  def execute(actor)
    self.__send__ @symbol, actor
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
  include Prototype
  
  attr_reader :list
  
  def initialize()
    @list = Hash.new
  end
  
  def has(count, sym, description = nil)
    @list[sym] = Array.new(count)
    description ||= sym
    #p 'define', sym, @list[sym]
    count.times {|i| @list[sym][i] = Component.new(sym, description) }
  end
  
  def players_have(count, sym, description = nil)
    has(count, sym, description)
  end

  def custom(which)
    yield(@list[which])
  end
  
  def cards(which, distribution)
    @list[which] = Array.new()
    distribution.each do |k, v|
      v.times { @list[which] << Component.new(which, k) }
    end
  end
  
  def shuffle(which)
    @list[which].shuffle!
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

class Board
  include Prototype
  
  def initialize(game)
    @game = game
    @decks = {}
  end
  
  def has(hash)
    hash.each {|k,v| instance_variable_set("@#{k}", v)}
    hash.each {|k,v| self.class.__send__(:attr_accessor, k)}
  end
  
  def deck(hash)
    hash.each {|k,v| has k => []; @decks[k] = v}
  end
  
  def reshuffle(area)
    areas(area).replace @game.components.shuffle :action
  end
  
  def all(area)
    areas(area).flatten.compact
  end

  def areas(area)
    instance_variable_get("@#{area}")
  end
  
  def choose_from(area)
    all(area).random
  end
  
  def draw_unique(area, to)
    begin 
      item = areas(area).pop
      if !yield(item)
        retry
      end
    end until !to.include?(item)
    #p item
    to << item
  end
  
  def remove(area, what)
    from = areas(area)
    remove_one(from, what)
  end
end

def rules_for(name, designer)
  game = Game.new(name, designer)
  yield(game)
  return game
end

Game.new(ARGV.shift)