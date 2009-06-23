require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/resource gsl/resource_user}

class GSL::Resource
  include Tattler
end

class User
  include GSL::ResourceUser
  attr_writer :world
end

describe "all tests", :shared => true do
  before :all do
    @user = User.new()
    @user.world = Yggdrasil::World.new
  end

  describe "before typing" do
    before do
      @class = GSL::Resource.define(:fudge)
      @object = @class.new(@user)
      modify
    end

    it_should_behave_like "well behaved objects"
    
    it "class has a name" do
      @class.name.should be_kind_of(Symbol)
    end

    it "object has a name" do
      @object.name.should be_kind_of(Symbol)
    end
    
    it "defaults to public" do
      @object.visible?(@user).should be_true
      @object.visible?(User.new()).should be_true
    end
    
    describe "with modified visibility" do
      before do
        @class = GSL::Resource.define(:ninjas)
        @object = @class.new(@user)
        modify
      end

      it "can be hidden" do
        @class.option.merge!(:visibility => :hidden)
        @object.visible?(@user).should be_false
        @object.visible?(User.new()).should be_false
      end

      it "can be private" do
        @class.option.merge!(:visibility => :private)
        @object.visible?(@user).should be_true
        @object.visible?(User.new()).should be_false
      end
    end
  end
  
  describe "typed as value" do
    before do
      @class = GSL::Resource.define(:fudge)
      @object = @class.new(@user)
      @initial_value = 8
      @object.set(@initial_value)
      modify
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
      modify
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
    
    it "to_s works with discards" do
      @object.discards
      @object.to_s.should be_kind_of(String)
    end
    
    it "spots recursive discarditis" do
      lambda {@object.discards.discards.to_s}.should raise_error(GSL::Language::Error)
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

    describe "without doesn't lose things in alterate realities" do
      it "when not modified" do
        alt = @object.without(:king) do
          @user.world.branch do
            @object.should_not include(:king)
          end
        end
        @user.world.switch(alt)
        @object.should include(:king)
      end

      it "when modified" do
        alt = @object.without(:king) do
          @user.world.branch do
            @object.lose :queen
          end
        end
        @object.should include(:queen)
        @user.world.switch(alt)
        @object.should_not include(:queen)
        @object.should include(:king)
      end
    end
  end
  
  describe "holding components" do
    before do
      @class = GSL::Resource.define(:frogs)
      @object = @class.new(@user)
      @initial_value = [GSL::Component.new(:ed, nil, @user.world), GSL::Component.new(:george, nil, @user.world)]
      @object.set(@initial_value)
      modify
    end
    
    it "lists names" do
      @object.names.should == @object.value.map {|c| c.name}
    end
  end

  describe "with discard option" do
    before do
      @class = GSL::Resource.define(:fruit)
      @class.option.merge! :discard_to => :compost_heap
      @object = @class.new(@user)
      @initial_value = [:apple, :pear, :banana]
      @object.set(@initial_value)
      modify
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

  describe "with deleted discard" do
    before do
      @user = User.new();
      @user.world = Yggdrasil::World.new
      @class = GSL::Resource.define(:vegitable)
      @object = @class.new(@user)
      @initial_value = [:carrot, :celery, :lettuce]
      @object.set(@initial_value)
      modify
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

    it "still has discards" do
      @object.discards.should be_kind_of(GSL::Resource::Set)
    end
  end
end

describe GSL::Resource do
  def modify; end
    
  it_should_behave_like "all tests"
end

describe GSL::Resource, "frozen" do
  def modify
    @object.freeze
  end
    
  it_should_behave_like "all tests"
end
