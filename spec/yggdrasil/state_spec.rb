require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{yggdrasil/state}

class Yggdrasil::State
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
  
  it "returns false if false" do
    @object[:true] = true
    @object[:false] = false
    @object[:true].should be_true
    @object[:false].should be_false
  end
  
  it "freezes values" do
    slippery = [1, 2, 3]
    @object[:slope] = slippery
    lambda {slippery << 4}.should raise_error
    @object[:slope].should == [1, 2, 3]
  end
  
  it "WARNING - doesn't freeze nested values" do
    slippery = [[1, 2, 3]]
    @object[:slope] = slippery
    lambda {slippery[0][0] = 42}.should_not raise_error
    @object[:slope].should == [[42, 2, 3]]
  end
  
  it "Updates immutable values" do
    @object[:blarg] = :bleep
    @object.update(:blarg) {|v| (v.to_s * 2).to_sym}
    @object[:blarg].should == :bleepbleep
  end

  it "Updates mutable values" do
    @object[:blarg] = [1, 2, 3]
    @object.update(:blarg) {|v| v << 4}
    @object[:blarg].should == [1, 2, 3, 4]
  end

  it "Updates with a default value" do
    @object.update(:blarg, :bleep) {|v| v.to_s.upcase.to_sym}
    @object[:blarg].should == :BLEEP
  end
  
  it "has a name" do
    @object.name.should be_kind_of(String)
  end
end

describe Yggdrasil::State do
  before do
    @top = @object = Yggdrasil::State.new
  end
  
  it_should_behave_like "well behaved objects"
  it_should_behave_like "state objects"
  
  it "derives new states" do
    @object.derive.should be_kind_of(Yggdrasil::State)
  end

  it "creates with a name" do
    Yggdrasil::State.new(nil, "barney").name.should == "barney"
  end

  describe "derived" do
    before do
      @object = @object.derive("child")
      @top[:parent] = :parent
      @object[:child] = :child
    end

    it_should_behave_like "state objects"
    
    it "has a parent" do
      @object.parent.should == @top
    end

    it "has a name" do
      @object.name.should == "child"
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
    
    it "writes nulls" do
      @object[:parent] = :child
      @object[:parent].should == :child
      @object[:parent] = nil
      @object[:parent].should == nil
    end
    
    it "Updates derived values" do
      @object.update(:parent) {|v| (v.to_s * 2).to_sym}
      @object[:parent].should == :parentparent
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
