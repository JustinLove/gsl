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
  
  it "responds to :in" do
    @object.should be_respond_to(:in)
  end
  
  it "sets actions" do
    GSL::Component.define_action("widget", lambda {$ran = true})
    @object.to_proc.should_not be_nil
  end
  
  it "executes actions" do
    $ran = false
    @object.to_proc.call
    $ran.should be_true
  end

  describe "from hash" do
  end
  
  describe "from array" do
  end
  
  describe "from fixnum" do
  end
end