require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/misc gsl/plan gsl/ygg}

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
  
  def note(s); end
  
  def stuff; [:stuff]; end
  
  def rate_state(s)
    if s[:legal]
      1
    else
      -1
    end
  end
end

describe GSL::Plan do
  before do
    @ground = GroundPlan.new
    @object = GSL::Plan.new(@ground, [1, 2, 3]) {}
    @bad = lambda{GSL::Game.illegal("badness")}
    @good = lambda{}
  end
  
  it_should_behave_like "well behaved objects"
  
  describe "takes different inputs" do
    it "takes arrays" do
      GSL::Plan.new(@ground, [1, 2, 3]){}.should_not be_nil
    end

    it "takes arrays" do
      GSL::Plan.new(@ground, [1, 2, 3]){}.should_not be_nil
    end

    it "takes hashs" do
      GSL::Plan.new(@ground, :one => 1, :two => 2){}.should_not be_nil
    end
    
    it "takes numbers" do
      GSL::Plan.new(@ground, 3){}.should_not be_nil
    end

    it "takes symbols" do
      GSL::Plan.new(@ground, :stuff){}.should_not be_nil
    end
    
    it "throws out the rest" do
      lambda {GSL::Plan.new(@ground, @ground)}.should raise_error
    end
  end
  
  it "is enumerable" do
    @object.map {|x| x}.should be_kind_of(Array)
  end
  
  it "returns a best element" do
    best = @object.best
    best.should_not be_nil
  end

  it "rates actions" do
    @object = GSL::Plan.new(@ground, [@good, @bad])
    @object.rate(@good).rating.should > @object.rate(@bad).rating
  end

  it "best rated illegal is illegal" do
    lambda {GSL::Plan.new(@ground, [@bad, @bad]).best}.
      should raise_error(GSL::Game::NoLegalOptions)
  end
  
  it "best rated nothing" do
    GSL::Plan.new(@ground, []).best.should be_kind_of(GSL::Future::Nil)
  end
  
  it "adds a rating" do
    best = @object.best
    best.rating.should be_kind_of(Numeric)
  end
  
  it "deferes later executions" do
    executions = 0
    good1 = lambda{executions += 1}
    good2 = lambda{executions += 1}
    bad1 = lambda{executions += 1; GSL::Game.illegal("badness")}
    bad2 = lambda{executions += 1; GSL::Game.illegal("badness")}
    GSL::Plan.new(@ground, [bad1, bad2, good1, good2]).best
    executions.should == 4
    executions = 0
    GSL::Plan.new(@ground, [bad1, bad2, good1, good2]).best
    executions.should == 1
  end
end
