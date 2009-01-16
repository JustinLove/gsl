require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{world}

class GSL::World::State
  include Tattler
end

class GSL::World::View
  include Tattler
end

describe GSL::World::State do
  before do
    @object = GSL::World::State.new
  end
  
  it_should_behave_like "well behaved objects"
  
  it "implements []" do
    @object[:blarg] = :bleep
    @object[:blarg].should == :bleep
  end
  
  it "derives new states" do
    @object.derive.should be_kind_of(GSL::World::State)
  end
end

describe GSL::World::View do
  before do
    @object = GSL::World::View.new
  end

  it_should_behave_like "well behaved objects"
end
