require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/future gsl/ygg}

class GSL::Future
  include Tattler
end

class Ground
  extend Yggdrasil::Citizen::Class
  ygg_accessor :stuff
  
  def initialize
    @world = Yggdrasil::World.new
    @world.state.name = "root"
    super
  end
  
  def execute(what, &doing)
    instance_eval(&what)
  end
  
  def rune; @w.rune(:stuff); end
  
  def note(s); end
end

describe GSL::Future do
  before do
    @ground = Ground.new
    @object = @legal = GSL::Future.new(@ground,
      lambda{self.stuff = :ran}, "legal")
    @illegal = GSL::Future.new(@ground,
      lambda{self.stuff = :garbage; raise GSL::Game::Illegal}, "illegal")
  end

  it_should_behave_like "well behaved objects"
  
  it "has a state" do
    @object.state.should_not be_nil
  end
  
  it "executes the method" do
    @object.state[@ground.rune].should == :ran
  end
  
  it "executes lazily" do
    blarg = nil
    f = GSL::Future.new(@ground, lambda{blarg = :bleep})
    f.should be_deferred
    blarg.should == nil
    f.force
    f.should_not be_deferred
    blarg.should == :bleep
  end

  it "marks legal" do
    @legal.legal?.should be_true
    @illegal.legal?.should be_false
  end

  it "has a reason" do
    @illegal.why_failed.should be_kind_of(Exception)
  end
  
  it "describes itself" do
    @legal.describe_action.should be_kind_of(String)
  end
  
  it "switches" do
    @illegal.switch.should == @illegal
    @ground.world[:legal].should be_false
  end
  
  it "doesn't croak on Nil" do
    lambda {GSL::Future::Nil.new.switch}.should_not raise_error
    @ground.world[:legal].should_not be_true
  end
  
  it "poisons the well" do
    ground = @ground
    poison = lambda{raise GSL::Game::Illegal}
    apple = lambda{GSL::Future.new(ground, poison, "poison").switch}
    GSL::Future.new(ground, apple, "well").legal?.should be_false
  end

  it "stays poisoned through multiple steps" do
    ground = @ground
    poison = lambda{raise GSL::Game::Illegal}
    apple = lambda{
      GSL::Future.new(ground, poison, "poison").switch
      GSL::Future.new(ground, lambda{}, "placebo").switch
    }
    GSL::Future.new(ground, apple, "well").legal?.should be_false
  end

  it "poisons all the way down" do
    ground = @ground
    poison = lambda{raise GSL::Game::Illegal}
    apple = lambda{GSL::Future.new(ground, poison, "poison").switch}
    basket = lambda{apple.call}
    GSL::Future.new(ground, basket, "well").legal?.should be_false
  end

  it "switches if legal" do
    @legal.switch_if_legal
    @ground.stuff.should == :ran
  end

  it "doesn't switch if not legal" do
    @illegal.switch_if_legal
    @ground.stuff.should_not == :garbage
  end
  
  it "knows how" do
    handy = GSL::Future.new(@ground,
      :hammer) {|tool| self.stuff = tool;}
    handy.state[@ground.rune].should == :hammer
  end
end
