require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{
  prototype classvar misc
  resource set_resource value_resource
  component resource_user}

class User
  include GSL::ResourceUser
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
    @user.stones.value.should include(:ruby)
  end
  
  it "query resources" do
    @user.has_resource?(:pebbles).should be_false
    @user.class.make_resource(:pebbles)
    @user.set_to 1, :pebbles
    @user.has_resource?(:pebbles).should be_true
  end
end