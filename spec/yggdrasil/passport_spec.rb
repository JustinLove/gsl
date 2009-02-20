require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{yggdrasil/passport yggdrasil/citizen yggdrasil/world}

class Yggdrasil::Passport
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
