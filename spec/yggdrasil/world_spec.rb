require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{yggdrasil/world}

class Yggdrasil::World
  include Tattler
end

describe Yggdrasil::World do
  before do
    @object = Yggdrasil::World.new
  end

  it_should_behave_like "well behaved objects"
  
  it "has a state" do
    @object.state.should be_kind_of(Yggdrasil::State)
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
  
  it "descends with a name" do
    @object.descend("down")
    @object.state.name.should == "down"
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
    @object.state.should be_kind_of(Yggdrasil::State)
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
    lambda {@object.ascend}.should raise_error
  end
  
  it "doesn't commit to nil" do
    @object.checkpoint
    lambda {@object.commit}.should raise_error
    @object.state.should be_kind_of(Yggdrasil::State)
  end
  
  it "branches" do
    @object[:blarg] = :bleep
    w = @object.branch do
      @object[:blarg] = :arg
    end
    w[:blarg].should == :arg
    @object[:blarg].should == :bleep
  end

  it "branches without changing reality" do
    truth = @object.reality
    w = @object.branch do
      @object.switch(@object.branch{})
    end
    @object.reality.should == truth
  end

  it "branches with a name" do
    w = @object.branch("fred") do
    end
    w.name.should == "fred"
  end
  
  it "switches" do
    @object.switch(@object.branch {@object[:leaf] = :green})
    @object[:leaf].should == :green
  end
end
