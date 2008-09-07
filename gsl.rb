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

  as_property :title
  as_property :author
  as_property :number_of_players
  as_proc :preparation

  @@master_common = {}
  
  def self.make_common(name, value)
    @@master_common[name] = Component.send(value.class.name.downcase, name, value)
  end
  
  def initialize(file)
    # http://www.artima.com/rubycs/articles/ruby_as_dsl.html
    self.instance_eval(File.read(file), file)
    self.play(@number_of_players.random)
  end
  
  def play(players)
    puts self
    @common = deep_copy(@@master_common)
    @players = Array.new(players) {Player.new}
    puts "#{@players.size} players"
    self.instance_eval(&@preparation)
  end
  
  def shuffle(deck)
    @common[deck].shuffle!
  end
  
  def each_player(&proc)
    @players.each {|p| p.instance_eval &proc}
  end
  
  def to_s
    "#{@title} by #{@author}, #{@number_of_players} players"
  end
  
  def common_components(list)
    list.each do |name,value|
      Game.make_common(name, value)
    end
  end
  
  def player_components(list)
    list.each do |name,value|
      Player.make_components(name, value)
    end
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

class Player
  include Prototype
  extend Prototype
  
  @@master_components = {}
  
  def self.make_components(name, value)
    @@master_components[name] = Component.send(value.class.name.downcase, name, value)
  end
  
  def initialize
    @components = deep_copy(@@master_components)
  end
end

Game.new(ARGV.shift)