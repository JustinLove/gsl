require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/plan gsl/ygg}

class GSL::Plan
  include Tattler
end

class GroundPlan
  extend Yggdrasil::Citizen::Class
  
  def initialize
    @world = Yggdrasil::World.new
    @world.state.name = "root"
    super
  end
  
  def stuff; :stuff; end
end

describe GSL::Plan do
  before do
    @ground = GroundPlan.new
    @object = GSL::Plan.new(@ground, [1, 2, 3])
  end
  
  it_should_behave_like "well behaved objects"
  
  describe "takes different inputs" do
    it "takes arrays" do
      GSL::Plan.new(@ground, [1, 2, 3]).should_not be_nil
    end

    it "takes arrays" do
      GSL::Plan.new(@ground, [1, 2, 3]).should_not be_nil
    end

    it "takes hashs" do
      GSL::Plan.new(@ground, :one => 1, :two => 2).should_not be_nil
    end
    
    it "takes numbers" do
      GSL::Plan.new(@ground, 3).should_not be_nil
    end

    it "takes symbols" do
      GSL::Plan.new(@ground, :stuff).should_not be_nil
    end
    
    it "throws out the rest" do
      lambda {GSL::Plan.new(@ground, @ground)}.should raise_error
    end
  end
  
  it "is enumerable" do
    @object.map {|x| x}.should == [1, 2, 3]
  end
  
  it "returns a best element" do
    best = @object.best
    best.should_not be_nil
  end
end
