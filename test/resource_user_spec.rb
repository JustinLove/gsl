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
end