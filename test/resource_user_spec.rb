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
end