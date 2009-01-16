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
end
