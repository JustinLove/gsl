require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{../yggdrasil}
require 'pp'

class Yggdrasil::State
  include Tattler
end

class Yggdrasil::World
  include Tattler
end

class Yggdrasil::Passport
  include Tattler
end

module Yggdrasil::Citizen
  include Tattler
end

class Kane
  include Tattler
  extend Yggdrasil::Citizen::Class
  ygg_accessor :blarg
  ygg_accessor :larry
  ygg_reader :china
  ygg_writer :sewer
  attr_accessor :w
  
  def initialize(_world)
    @world = _world
    super()
  end
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

describe Yggdrasil::Passport do
  before do
    @world = Yggdrasil::World.new
    @object = Yggdrasil::Passport.new(Kane.new(@world))
    @other = Yggdrasil::Passport.new(Kane.new(@world))
  end
  
  it_should_behave_like "well behaved objects"

  it "has key generator" do
    @object.id_card(:blarg).should be_kind_of(String)
  end
  
  it "stores values" do
    @object[:blarg] = :bleep
    @object[:blarg].should == :bleep
  end
  
  it "has update shorthand" do
    @object[:blarg] = :bleep
    @object.update(:blarg) {|v| v.to_s.upcase.to_sym}
    @object[:blarg].should == :BLEEP
  end

  it "stores attributes in the world" do
    @world.begin
    @object[:larry] = :dead
    @world.abort
    @object[:larry].should_not == :dead
  end
  
  it "stores attributes independently" do
    @object[:blarg] = :bleep
    @object[:larry] = :happy
    @object[:blarg].should == :bleep
    @object[:larry].should == :happy
  end
  
  it "stores objects independently" do
    @object[:larry] = :happy
    @other[:larry] = :sad
    @object[:larry].should == :happy
    @other[:larry].should == :sad
  end
end

describe Yggdrasil::Citizen do
  before do
    @world = Yggdrasil::World.new
    @object = Kane.new(@world)
    @other = Kane.new(@world)
  end

  it_should_behave_like "well behaved objects"

  it "exposes it's world" do
    @object.world.should == @world
  end
  
  it "has attributes" do
    @object.blarg = :bleep
    @object.blarg.should == :bleep
  end
  
  it "has readables" do
    @object.should respond_to(:china)
    @object.should_not respond_to(:china=)
  end

  it "has writeables" do
    @object.should_not respond_to(:sewer)
    @object.should respond_to(:sewer=)
  end
  
  it "has internal access" do
    @object.w[:china] = :bejing
    @object.china.should == :bejing
    @object.sewer = :rain
    @object.w[:sewer].should == :rain
  end
  
  it "has update shorthand" do
    @object.blarg = :bleep
    @object.w.update(:blarg) {|v| v.to_s.upcase.to_sym}
    @object.blarg.should == :BLEEP
  end
  
  it "stores attributes in the world" do
    @world.begin
    @object.larry = :dead
    @world.abort
    @object.larry.should_not == :dead
  end
  
  it "stores attributes independently" do
    @object.blarg = :bleep
    @object.larry = :happy
    @object.blarg.should == :bleep
    @object.larry.should == :happy
  end
  
  it "stores objects independently" do
    @object.larry = :happy
    @other.larry = :sad
    @object.larry.should == :happy
    @other.larry.should == :sad
  end
end