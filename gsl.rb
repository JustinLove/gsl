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
  
  def components(list)
    list.each do |name,value|
      Component.make(name, value)
    end
  end
end

class Component
  include Prototype
  extend Prototype
  
  @@components = {}
  
  def initialize(name)
    @name = name
  end
  
  def self.make(name, value)
    @@components[name] = Component.send(value.class.name.downcase, name, value)
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
    @@components.inspect
  end
  
  def to_s
    @name
  end
end

Game.new(ARGV.shift)