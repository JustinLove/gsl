require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{resource resource_user}

class GSL::Resource
  include Tattler
end

class User
  include GSL::ResourceUser
end

describe GSL::Resource do
  before :all do
    @user = User.new()
  end

  describe "before typing" do
    before do
      @class = GSL::Resource.define(:fudge)
      @object = @class.new(@user)
    end

    it_should_behave_like "well behaved objects"
    
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

    it "should not reference the initializer" do
      @object.value.should_not equal(@initial_value)
    end
    
    it "forwards unknown messages" do
      lambda{@object.uniq}.should_not raise_error
    end
    
    it "gains" do
      @object.gain([:jack])
      @object.value.should include(:jack)
    end
    
    it "loses" do
      @object.lose([:king])
      @object.value.should_not include(:king)
    end
    
    it "loses all" do
      @object.lose(:all).should == @initial_value
    end

    it "wraps scalars" do
      @object.gain(:jack)
      @object.value.should include(:jack)
    end
    
    it "shuffles" do
      different = 0
      3.times do
        @object.shuffle
        different += 1 unless(@object.value == @initial_value)
        @initial_value.permutation.should include(@object.value)
      end
      different.should > 0
    end
    
    it "has discards" do
      @object.discards.should be_kind_of(GSL::Resource::Set)
    end
    
    it "reshuffles" do
      @object.discards.gain([:jack])
      @object.reshuffle
      @object.discards.value.should == []
      @object.value.should include(:jack)
    end
    
    it "draws" do
      @initial_value.each do |c|
        @object.draw.should == c
      end
    end

    it "calls the draw filter" do
      called = false
      @object.draw{|c| called = c}.should == called
    end

    it "filter can change the value" do
      @object.draw{:jack}.should == :jack
    end
    
    it "remembers it's filter" do
      @object.draw{:jack}
      @object.draw.should == :jack
    end

    it "checks includes" do
      @object.should include(:king)
      @object.should_not include(:jack)
    end
    
    it "can temporarily remove something" do
      @object.without(:king) {@object.should_not include(:king)}
      @object.should include(:king)
    end
  end
  
  describe "with discard option" do
    before do
      @class = GSL::Resource.define(:fruit)
      @class.option.merge! :discard_to => :compost_heap
      @object = @class.new(@user)
      @initial_value = [:apple, :pear, :banana]
      @object.set(@initial_value)
    end
    
    it "has discards" do
      @object.discards.should be_kind_of(GSL::Resource::Set)
    end

    it "has specified discards" do
      @object.discards.name.should == :compost_heap
    end

    it "reshuffles" do
      @object.discards.gain([:jack])
      @object.reshuffle
      @object.discards.value.should == []
      @object.value.should include(:jack)
    end
  end
end
