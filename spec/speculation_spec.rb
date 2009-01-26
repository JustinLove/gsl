require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{speculation world}

class GSL::Speculation
  include Tattler
end

class Ground
  extend GSL::World::Citizen::Class
  ver_accessor :stuff
  
  def initialize
    @world = GSL::World::View.new
    super
  end
end

describe GSL::Speculation do
  before do
    @ground = Ground.new
    @object = @legal = GSL::Speculation.new(@ground,
      lambda{self.stuff = :ran}, "nothing much")
    @illegal = GSL::Speculation.new(@ground,
      lambda{raise GSL::GamePlayException}, "an error")
  end

  it_should_behave_like "well behaved objects"
  
  it "has a state" do
    @object.state.should_not be_nil
  end
  
  it "executes the method" do
    @object.state[:stuff] == :ran
  end
  
  it "provides [] for backwards compatibiltiy" do
    @object[:action].should == @object.action
  end
  
  it "marks legal" do
    @legal.legal?.should be_true
    @illegal.legal?.should be_false
  end
end
