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
      lambda{self.stuff = :ran}, "nothing much")
    @illegal = GSL::Speculation.new(@ground,
      lambda{self.stuff = :garbage; raise GSL::Game::Illegal}, "an error")
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
    @illegal.switch
    @ground.world[:legal].should be_false
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
