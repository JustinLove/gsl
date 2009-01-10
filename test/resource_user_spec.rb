require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{resource_user}

class User
  include GSL::ResourceUser
end

class Front
  include GSL::ResourceUser
  def initialize(target)
    @target = target
  end
  def forward_to; @target; end
end

describe GSL::ResourceUser do
  before do
    @user = User.new()
    @user.resource_init
  end
  
  it "has classvars" do
    @user.cv.resources.should be_kind_of(Array)
    @user.cv.components.should be_kind_of(Hash)
  end
  
  it "makes components" do
    @user.class.make_components(:cubes, 10)
    @user.cv.components[:cubes].first.should be_kind_of(GSL::Component)
    @user.cv.resources.should include(:cubes)
  end
  
  it "makes resources" do
    @user.class.make_resource(:score)
    @user.cv.resources.should include(:score)
    @user.score.should be_kind_of(GSL::Resource)
    @user.set_to 5, :score
    @user.score.value.should == 5
  end
  
  it "responds to resource names" do
    @user.should_not respond_to(:tickles)
    @user.class.make_resource(:tickles)
    @user.should respond_to(:tickles)
  end

  it "has methods for resource names" do
    lambda {@user.giggles}.should raise_error
    @user.class.make_resource(:giggles)
    lambda {@user.giggles}.should_not raise_error
  end

  describe "make resources with bounds" do
    before do
      @user.class.make_resource(:spoons, 1..7)
      @user.set_to 1, :spoons
    end
  
    it "that accept valid values" do
      @user.spoons.value.should == 1
    end
    
    it "that reject invalid values " do
      lambda{@user.set_to 8, :spoons}.should raise_error
      @user.spoons.value.should <= 7
    end
  end

  it "makes resources with options" do
    @user.class.make_resource(:fruit, 0..Infinity, :discard_to => :compost)
    @user.set_to [:apple, :pear], :fruit
    @user.fruit.discards.name.should == :compost
  end
  
  it "makes resources with procs" do
    @user.class.make_resource(:bits) do
      def ground
        self
      end
    end
    @user.bits.should respond_to(:ground)
    @user.bits.ground.should == @user.bits
  end
  
  it "uses components to make resources" do
    @user.class.make_components(:stones, [:ruby, :emerald])
    @user.stones.value.map{|i| i.name}.should include(:ruby)
  end
  
  it "querys resources" do
    @user.has_resource?(:pebbles).should be_false
    @user.class.make_resource(:pebbles)
    @user.set_to 1, :pebbles
    @user.has_resource?(:pebbles).should be_true
  end

  it "supports resource method" do
    @user.class.make_resource(:money)
    @user.set_to 1, :money
    @user.resource(:money).should be_kind_of(GSL::Resource)
  end
  
  it "creates resources through resource method" do
    @user.resource(:cheese).should be_kind_of(GSL::Resource)
  end
  
  it "supports forward_to" do
    @user.forward_to.should be_false
  end
  
  describe "forwards to another user" do
    before do
      @front = Front.new(@user)
      @front.resource_init
    end
    
    it "forwards_to user" do
      @front.forward_to.should == @user
    end
    
    it "forwards resource names" do
      @front.respond_to?(:red_tape).should be_false
      @user.class.make_resource(:red_tape)
      @user.set_to 100, :red_tape
      @front.respond_to?(:red_tape).should be_true
      @front.has_resource?(:red_tape).should be_false
      @front.red_tape.should == @user.red_tape
    end

    it "forwards resource methods" do
      @user.class.make_resource(:blue_tape)
      @user.set_to 100, :blue_tape
      @front.gain 5, :blue_tape
      @user.blue_tape.value.should == 105
    end
  end
end