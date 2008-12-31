require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{prototype properties misc resource set_resource value_resource}

describe GSL::Resource do
  describe "before typing" do
    before do
      @class = GSL::Resource.define(:fudge)
      @object = @class.new(self)
    end
    
    it "class should have a name" do
      @class.name.should be_kind_of(Symbol)
    end

    it "object should have a name" do
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
end
