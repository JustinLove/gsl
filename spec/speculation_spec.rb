require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{speculation world}

class GSL::Speculation
  include Tattler
end

class Ground
  extend GSL::World::Citizen::Class
  
  def initialize
    @world = GSL::World::View.new
    super
  end
end

describe GSL::Speculation do
  before do
    @ground = Ground.new
    @object = GSL::Speculation.new(@ground, lambda{}, "nothing much")
  end

  it_should_behave_like "well behaved objects"
  
  it "has a state" do
    @object.state.should_not be_nil
  end
  
  it "marks legal" do
    @object.state[:legal].should be_true
  end
end
