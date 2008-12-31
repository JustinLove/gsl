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
      @object.set(8)
    end
    
    it "should have a value" do
      @object.value.should == 8
    end
  end
end
