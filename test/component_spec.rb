require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{component}
libs %w{resource resource_user}

class User
  include GSL::ResourceUser
end

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

  it "has a name" do
    @object.name.should == "widget"
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
    before do
      @list = GSL::Component.array("cards", [:king, :queen, :jack])
    end
    
    it "made something" do
      @list.should_not be_nil
    end
    
    it "has the same quantity" do
      @list.length.should == 3
    end
    
    it "includes all items" do
      names = @list.map {|i| i.name}
      names.should include(:king)
      names.should include(:jack)
      names.should include(:queen)
    end
  end
  
  describe "from fixnum" do
    before do
      @list = GSL::Component.fixnum("cubes", 5)
    end
    
    it "made something" do
      @list.should_not be_nil
    end
    
    it "has the same quantity" do
      @list.length.should == 5
    end
    
    it "has a name" do
      @list.first.name.should == "cubes"
    end
  end
  
  describe "tracks location" do
    before :all do
      @user = User.new()
      @user.resource_init
    end
    
    before do
      @class = GSL::Resource.define(:cards)
      @resource = @class.new(@user)
      @initial_value = GSL::Component.array(:cards, [:ace, :queen, :king])
      @resource.set(@initial_value)
      @object = @resource.first
    end
    
    it "should be in the deck" do
      @object.in.should == @resource
    end

    it "leaves it's deck" do
      @object.discard
      
      @object.in.should_not == @resource
      @resource.should_not include(@object)
    end
    
    it "goes to the discard pile" do
      @object.discard
      
      @object.in.should == @resource.discards
      @resource.discards.should include(@object)
    end
    
    it "goes to a different discard pile" do
      alt = GSL::Resource.define(:floor).new(@user)
      alt.set([])
      @object.discard(alt)
      
      @object.in.should_not == @resource.discards
      @resource.discards.should_not include(@object)
      @object.in.should == alt
      alt.should include(@object)
    end
  end
end