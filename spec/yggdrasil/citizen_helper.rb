require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{yggdrasil/citizen}

class Kane
  include Tattler
  extend Yggdrasil::Citizen::Class
  ygg_accessor :blarg
  ygg_accessor :larry
  ygg_reader :china
  ygg_writer :sewer
  ygg_property :dashing
  attr_accessor :w
  
  def initialize(_world)
    @world = _world
    super()
  end
end

