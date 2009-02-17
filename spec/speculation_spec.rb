require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{speculation world}

class GSL::Speculation
  include Tattler
end

class Ground
  extend Yggdrasil::Citizen::Class
  ver_accessor :stuff
  
  def initialize
    @world = Yggdrasil::View.new
    @world.state.name = "root"
    super
  end
  
  def execute(what, &doing)
    instance_eval(&what)
  end
  
  def card; @w.id_card(:stuff); end
  
  def note(s); end
end

describe GSL::Speculation do
  before do
    @ground = Ground.new
    @object = @legal = GSL::Speculation.new(@ground,
      lambda{self.stuff = :ran}, "legal")
    @illegal = GSL::Speculation.new(@ground,
      lambda{self.stuff = :garbage; raise GSL::Game::Illegal}, "illegal")
  end

  it_should_behave_like "well behaved objects"
  
  it "has a state" do
    @object.state.should_not be_nil
  end
  
  it "executes the method" do
    @object.state[@ground.card].should == :ran
  end

  it "marks legal" do
    @legal.legal?.should be_true
    @illegal.legal?.should be_false
  end

  it "has a reason" do
    @illegal.why_failed.should be_kind_of(Exception)
  end
  
  it "switches" do
    @illegal.switch.should == @illegal
    @ground.world[:legal].should be_false
  end
  
  it "doesn't croak on Nil" do
    lambda {GSL::Speculation::Nil.new.switch}.should_not raise_error
    @ground.world[:legal].should_not be_true
  end
  
  it "poisons the well" do
    ground = @ground
    poison = lambda{raise GSL::Game::Illegal}
    apple = lambda{GSL::Speculation.new(ground, poison, "poison").switch}
    GSL::Speculation.new(ground, apple, "well").legal?.should be_false
  end

  it "stays poisoned through multiple steps" do
    ground = @ground
    poison = lambda{raise GSL::Game::Illegal}
    apple = lambda{
      GSL::Speculation.new(ground, poison, "poison").switch
      GSL::Speculation.new(ground, lambda{}, "placebo").switch
    }
    GSL::Speculation.new(ground, apple, "well").legal?.should be_false
  end

  it "poisons all the way down" do
    ground = @ground
    poison = lambda{raise GSL::Game::Illegal}
    apple = lambda{GSL::Speculation.new(ground, poison, "poison").switch}
    basket = lambda{apple.call}
    GSL::Speculation.new(ground, basket, "well").legal?.should be_false
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
    handy = GSL::Speculation.new(@ground,
      :hammer) {|tool| self.stuff = tool;}
    handy.state[@ground.card].should == :hammer
  end
end
