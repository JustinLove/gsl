require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{prototype misc resource set_resource value_resource}

describe GSL::Resource do
  describe "before typing" do
    before do
      @class = GSL::Resource.define(:fudge)
      @object = @class.new(self)
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
      @object = @class.new(self)
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
      @object = @class.new(self)
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
  end
end
