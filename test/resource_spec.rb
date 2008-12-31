require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{prototype properties misc resource set_resource value_resource}

describe GSL::Resource do
  describe "before typing" do
    before do
      @object = @res = GSL::Resource.define(:fudge)
    end
    
    it "should have a name" do
      @res.name.should be_kind_of(Symbol)
    end
  end
end
