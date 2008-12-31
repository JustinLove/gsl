require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{
  prototype classvar misc
  resource set_resource value_resource
  resource_user}

class User
  include GSL::ResourceUser
end

describe GSL::Resource do
  before do
    @user = User.new()
    @user.resource_init
  end

  describe "before typing" do
    before do
      @class = GSL::Resource.define(:fudge)
      @object = @class.new(@user)
    end
    
    it "class has a name" do
      @class.name.should be_kind_of(Symbol)
    end

    it "object has a name" do
      @object.name.should be_kind_of(Symbol)
    end
  end
  
  describe "typed as value" do
    before do
      @class = GSL::Resource.define(:fudge)
      @object = @class.new(@user)
      @initial_value = 8
      @object.set(@initial_value)
    end
    
    it "has a value" do
      @object.value.should == @initial_value
    end
    
    it "gains" do
      @object.gain(1)
      @object.value.should > @initial_value
    end
    
    it "loses" do
      @object.lose(1)
      @object.value.should < @initial_value
    end
  end
  
  describe "typed as set" do
    before do
      @class = GSL::Resource.define(:cards)
      @object = @class.new(@user)
      @initial_value = [:ace, :queen, :king]
      @object.set(@initial_value)
    end
    
    it "has a value" do
      @object.value.should == @initial_value
    end
    
    it "gains" do
      @object.gain([:jack])
      @object.value.should include(:jack)
    end
    
    it "loses" do
      @object.lose([:king])
      @object.value.should_not include(:king)
    end

    it "wraps scalars" do
      @object.gain(:jack)
      @object.value.should include(:jack)
    end
    
    it "has discards" do
      @object.discards.should be_kind_of(GSL::Resource::Set)
    end
  end
end
