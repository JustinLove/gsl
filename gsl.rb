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
    # http://www.artima.com/rubycs/articles/ruby_as_dsl.html
    self.instance_eval(File.read(file), file)
    puts self
  end
  
  def to_s
    "#{@title} by #{@author}, #{@players} players"
  end
  
  def common_components(list)
    list.each do |name,value|
      Component.make_common(name, value)
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
  
  @@common = {}
  
  def initialize(name)
    @name = name
  end
  
  def self.make_common(name, value)
    @@common[name] = Component.send(value.class.name.downcase, name, value)
  end

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
  
  def self.to_s
    @@common.inspect
  end
  
  def to_s
    @name
  end
end

class Player
  include Prototype
  extend Prototype
  
  @@components = {}
  
  def self.make_components(name, value)
    @@components[name] = Component.send(value.class.name.downcase, name, value)
  end
end

Game.new(ARGV.shift)