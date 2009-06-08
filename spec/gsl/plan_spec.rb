require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/misc gsl/plan gsl/ygg gsl/future}

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

shared_examples_for "well behaved plans" do
  
  describe "takes different inputs" do
    it "takes arrays" do
      @class.new(@ground, [1, 2, 3]){}.should_not be_nil
    end

    it "takes arrays" do
      @class.new(@ground, [1, 2, 3]){}.should_not be_nil
    end

    it "takes hashs" do
      @class.new(@ground, :one => 1, :two => 2){}.should_not be_nil
    end
    
    it "takes numbers" do
      @class.new(@ground, 3){}.should_not be_nil
    end

    it "takes symbols" do
      @class.new(@ground, :stuff){}.should_not be_nil
    end
    
    it "throws out the rest" do
      lambda {@class.new(@ground, @ground)}.should raise_error
    end
  end
  
  it "is enumerable" do
    @object.map {|x| x}.should be_kind_of(Array)
  end
  
  it "returns a best element" do
    best = @object.best
    best.should_not be_nil
  end

  it "best rated illegal is illegal" do
    lambda {@class.new(@ground, [@bad, @bad]).best}.
      should raise_error(GSL::Game::NoLegalOptions)
  end
  
  it "best rated nothing" do
    @class.new(@ground, []).best.should be_kind_of(GSL::Future::Nil)
  end
end

describe GSL::Plan do
  before do
    @ground = GroundPlan.new
    @bad = lambda{GSL::Game.illegal("badness")}
    @good = lambda{}
  end
  
  describe GSL::Plan::Cached do
    before do
      @class = GSL::Plan::Cached
      @object = @class.new(@ground, [1, 2, 3]) {}
    end
      
    it_should_behave_like "well behaved objects"
    it_should_behave_like "well behaved plans"
  
    it "deferes later executions" do
      executions = 0
      good1 = lambda{executions += 1}
      good2 = lambda{executions += 1}
      bad1 = lambda{executions += 1; GSL::Game.illegal("badness")}
      bad2 = lambda{executions += 1; GSL::Game.illegal("badness")}
      @class.new(@ground, [bad1, bad2, good1, good2]).best
      executions.should == 4
      executions = 0
      @class.new(@ground, [bad1, bad2, good1, good2]).best
      executions.should == 1
    end
  end
  
  describe GSL::Plan::BroadShallow do
    before do
      @class = GSL::Plan::BroadShallow
      @object = @class.new(@ground, [1, 2, 3]) {}
    end
      
    it_should_behave_like "well behaved objects"
    it_should_behave_like "well behaved plans"
  end

  describe GSL::Plan::Random do
    before do
      @class = GSL::Plan::Random
      @object = @class.new(@ground, [1, 2, 3]) {}
    end
      
    it_should_behave_like "well behaved objects"
    it_should_behave_like "well behaved plans"
  end

  describe GSL::Plan::Biased do
    before do
      @class = GSL::Plan::Biased
      @object = @class.new(@ground, [1, 2, 3]) {}
    end
      
    it_should_behave_like "well behaved objects"
    it_should_behave_like "well behaved plans"
    
    it "makes propotinal choice" do
      @ok = lambda{}
      g = GSL::Future.new(@ground, @good).describe_action
      o = GSL::Future.new(@ground, @ok).describe_action
      10.times do
        @class.feedback(g, 1)
        @class.feedback(o, 0)
      end
      (1..100).inject(0) {|s,x|
        s + (@class.new(@ground, [@good, @ok]).best.what == @good ? 1 : 0)
      }.should > 70
    end
  end
end
