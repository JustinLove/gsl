require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{world}

class GSL::World::State
  include Tattler
end

class GSL::World::View
  include Tattler
end

shared_examples_for "state objects" do
  it "implements []" do
    @object[:blarg] = :bleep
    @object[:blarg].should == :bleep
  end
  
  it "returns nil for unknown keys" do
    @object[:foo].should be_nil
  end
end

describe GSL::World::State do
  before do
    @top = @object = GSL::World::State.new
  end
  
  it_should_behave_like "well behaved objects"
  it_should_behave_like "state objects"
  
  it "derives new states" do
    @object.derive.should be_kind_of(GSL::World::State)
  end
  
  describe "derived" do
    before do
      @object = @object.derive
    end

    it_should_behave_like "state objects"
    
    it "has a parent" do
      @object.parent.should == @top
    end
    
    it "retrieves parent values" do
      @top[:parent] = :parent
      @object[:parent].should == :parent
    end
    
    it "does not create parent values" do
      @object[:child] = :child
      @top[:child].should be_nil
    end

    it "does not change parent values" do
      @top[:parent] = :parent
      @object[:parent] = :child
      @top[:parent].should == :parent
    end
  end
end

describe GSL::World::View do
  before do
    @object = GSL::World::View.new
  end

  it_should_behave_like "well behaved objects"
  
  it "has a state" do
    @object.state.should be_kind_of(GSL::World::State)
  end
  
  it "forwards []" do
    @object.state[:blarg] = :bleep
    @object[:blarg].should == :bleep
  end
  
  it "forwards []=" do
    @object[:blarg] = :bleep
    @object.state[:blarg].should == :bleep
  end
  
  it "descends" do
    @object[:blarg] = :bleep
    @object.descend
    @object[:blarg].should == :bleep
  end
  
  it "ascends" do
    @object.descend
    @object[:larry] = :dead
    @object.ascend
    @object[:larry].should_not == :dead
  end
  
  it "begins" do
    @object[:blarg] = :bleep
    @object.begin
    @object[:blarg].should == :bleep
  end
  
  it "aborts" do
    @object.begin
    @object[:larry] = :dead
    @object.abort
    @object[:larry].should_not == :dead
  end
  
  it "doesn't ascend to nil" do
    lambda {@object.ascend}.should raise_error
    @object.state.should be_kind_of(GSL::World::State)
  end
  
  it "commits" do
    @object.begin
    @object[:cancer] = :cured
    @object.commit
    @object[:cancer].should == :cured
    lambda {@object.ascend}.should raise_error
  end
end
