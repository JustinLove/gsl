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
    before do
      @list = GSL::Component.hash("cards", :king => 1, :jack => 2, :queen => 3)
    end
    
    it "made something" do
      @list.should_not be_nil
    end
    
    it "expands quantity" do
      @list.length.should == 6
    end
    
    it "includes all items" do
      names = @list.map {|i| i.name}
      names.should include(:king)
      names.should include(:jack)
      names.should include(:queen)
    end
  end
  
  describe "from array" do
  end
  
  describe "from fixnum" do
  end
end