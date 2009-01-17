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
      @top[:parent] = :parent
      @object[:child] = :child
    end

    it_should_behave_like "state objects"
    
    it "has a parent" do
      @object.parent.should == @top
    end
    
    it "retrieves parent values" do
      @object[:parent].should == :parent
    end
    
    it "does not create parent values" do
      @top[:child].should be_nil
    end

    it "does not change parent values" do
      @object[:parent] = :child
      @top[:parent].should == :parent
    end
    
    it "clones" do
      @betty = @object.clone
      @betty[:child].should == :child
      @betty[:parent].should == :parent
      @betty[:child] = :dennis
      @object[:child].should == :child
    end
    
    it "merges" do
      @object[:color] = :red
      @top[:color] = :blue
      @new_state = @object.merge
      @new_state.should_not == @object
      @new_state.should_not == @top
      @new_state[:parent].should == :parent
      @new_state[:child].should == :child
      @new_state[:color].should == :red
      @top[:parent].should == :parent
      @top[:child].should be_nil
      @top[:color].should == :blue
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
  
  it "abort-commit" do
    @object[:something] = :strange
    @object.begin
    @object.begin
    @object[:something] = :foul
    @object.abort
    @object[:something].should_not == :foul
    @object[:something] = :fair
    @object.commit
    @object[:something].should == :fair
  end

  it "commit-abort" do
    @object[:something] = :strange
    @object.begin
    @object.begin
    @object[:something] = :fair
    @object.commit
    @object[:something].should == :fair
    @object[:something] = :foul
    lambda {@object.abort}.should_not raise_error
    @object[:something].should == :strange
  end

  it "checkpoints" do
    @object.checkpoint
    @object.state.parent.should_not be_nil
    lambda {@objet.ascend}.should raise_error
  end
  
  it "doesn't commit to nil" do
    @object.checkpoint
    lambda {@object.commit}.should raise_error
    @object.state.should be_kind_of(GSL::World::State)
  end
  
end
