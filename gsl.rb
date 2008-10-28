Infinity = 1.0/0

def Error(*args); throw *args; end

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

class Range
  def random
    self.first + rand(self.last + 1 - self.first)
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
  def as_proc(named)
    define_method(named) do |&proc|
      instance_variable_set("@#{named}", proc)
    end
  end
end

def deep_copy(obj)
  Marshal::load(Marshal.dump(obj))
end

class Game
  include Prototype
  extend Properties

  attr_reader :players

  as_property :title
  as_property :author
  as_property :number_of_players

  @@master_components = {}
  @@common_resources = []
  
  def self.make_componenets(name, value)
    @@master_components[name] = Component.send(value.class.name.downcase, name, value)
  end
  
  def self.make_resource(name)
    @@common_resources << name
  end
  
  def initialize(file)
    # http://www.artima.com/rubycs/articles/ruby_as_dsl.html
    self.instance_eval(File.read(file), file)
    self.go(@number_of_players.random)
  end
  
  def common_components(list)
    list.each do |name,value|
      Game.make_componenets(name, value)
    end
  end
  
  def player_components(list)
    list.each do |name,value|
      Player.make_components(name, value)
    end
  end
  
  def create_resource(name, range = 0..Infinity, option = nil, &proc)
    r = Resource.define(name)
    r.range = range
    r.option = option
    if (!proc.nil?)
      r.__send__ :include, Module.new(&proc)
    end
    r
  end

  def common_resource(name, range = 0..Infinity, option = nil, &proc)
    create_resource(name, range, option, &proc)
    Game.make_resource(name)
  end

  def player_resource(name, range = 0..Infinity, option = nil, &proc)
    create_resource(name, range, option, &proc)
    Player.make_resource(name)
  end

  def go(players)
    puts self
    @common = deep_copy(@@master_components)
    @players = Array.new(players) {Player.new(self)}
    puts "#{@players.size} players"
    play
  end
  
  def shuffle(deck)
    @common[deck].shuffle!
  end
  
  def each_player(&proc)
    @players.each {|pl| pl.instance_eval &proc}
  end
  
  def starting_player_is(spec)
  end
  
  def at_any_time(action, &proc)
    Player.at_any_time(action, proc)
  end

  def to(name, &proc)
    self.class.__send__ :define_method, name, &proc
  end
  
  alias every to
  
  def game_over
    @rounds ||= 0
    return (@rounds = @rounds + 1) > @players.length
  end
    
  def to_s
    "#{@title} by #{@author}, #{@number_of_players} players"
  end
    
end

class Component
  include Prototype
  extend Prototype
  
  def self.hash(name, value)
    list = []
    value.each do|k,v|
      v.times {list << Component.new(k)}
    end
    array(name, list)
  end
  
  def self.array(name, value)
    value
  end
  
  def self.fixnum(name, value)
    list = []
    value.times {list << Component.new(name)}
    array(name, list)
  end
  
  def initialize(name)
    @name = name
  end
  
  def to_s
    @name
  end
end

module Resource_Template
end


class Resource
  class << self
    alias :class_name :name
    attr_accessor :name, :range, :option
    def to_s
      if name then
        "#{name} #{range}"
      else
        super
      end
    end
    def define(name)
      const_name = name.to_s.capitalize
      if (const_defined?(const_name))
        return const_get(const_name)
      end
      return const_set(const_name, Class.new(self) do
        @name = name
        @range = 0..Infinity
        @option = nil
      end)
    end
  end

  include Prototype
  extend Properties

  attr_accessor :value

  def set(n)
    if (n.kind_of? Numeric)
      class << self
        include Value_Resource
      end
      self.set(n)
    elsif (n.kind_of? Enumerable)
      class << self
        include Set_Resource
      end
    else
      throw "can't have that kind of resource"
    end
  end
end

module Value_Resource
  def set(n)
    if self.class.range.include?(n)
      @value = n
    else
      throw 'resource out of range'
    end
  end

  def change(n)
    if self.class.range.include?(@value+n)
      @value += n
    else
      throw InsufficientResources(name, @value, n)
    end
  end

  alias :gain :change
  
  def lose(n)
    self.change(-n)
  end
end

module Set_Resource
  def set(n)
    if self.class.range.include?(n.size)
      @value = n
    else
      throw 'resource out of range'
    end
  end

  def gain(n)
    possible = @value + n
    if self.class.range.include?(possible.size)
      @value = possible
    else
      throw InsufficientResources(name, @value, n)
    end
  end

  def gain(lose)
    possible = @value - n
    if @value.include?(n) && self.class.range.include?(possible.size)
      @value = possible
    else
      throw InsufficientResources(name, @value, n)
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
  extend Prototype
  
  attr_reader :color
  
  @@master_components = {}
  @@player_resources = []
  @@any_time = []
  
  def self.make_components(name, value)
    @@master_components[name] = Component.send(value.class.name.downcase, name, value)
  end
  
  def self.make_resource(name)
    @@player_resources << name
  end
  
  def self.at_any_time(action, proc)
    define_method(action, proc)
    @@any_time << action
  end
  
  def initialize(game)
    @game = game
    @components = deep_copy(@@master_components)
    @resources = Hash.new do |hash, key|
      hash[key] = Resource.define(key).new
    end
  end
  
  def set_to(n, *resources)
    resources.each {|r| @resources[r].set(n)}
  end
  
  def change_resource(n, resource)
    @resources[resource].change(n)
  end

  alias :gain :change_resource
  
  def lose(n, resource)
    change_resource(-n, resource)
  end
  
  def pick_color(*choices)
    @color = (choices - @game.players.map {|pl| pl.color}).random
  end
  
  def to_s
    "#{@color} player #{@resources.inspect}"
  end
  
end

Game.new(ARGV.shift)