require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{../yggdrasil/citizen ../yggdrasil/world}

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
