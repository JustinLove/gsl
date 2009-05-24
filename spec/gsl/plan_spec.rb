require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/plan gsl/ygg}

class GSL::Plan
  include Tattler
end

class Ground
  extend Yggdrasil::Citizen::Class
  
  def initialize
    @world = Yggdrasil::World.new
    @world.state.name = "root"
    super
  end
end

describe GSL::Plan do
  before do
    @ground = Ground.new
    @object = GSL::Plan.new(@ground, [])
  end
  
  it_should_behave_like "well behaved objects"
  
end
