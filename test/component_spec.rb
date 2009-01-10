require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{component}

describe GSL::Component do
  before do
    @object = GSL::Component.new("widget")
  end
  
  it "gets created" do
    @object.should be_kind_of(GSL::Component)
  end
  
  it "has a string rep" do
    @object.to_s.should be_kind_of(String)
  end
  
  describe "from hash" do
  end
  
  describe "from array" do
  end
  
  describe "from fixnum" do
  end
end