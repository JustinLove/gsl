require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{world}

describe GSL::World::State do
  before do
    @object = GSL::World::State.new
  end
end

describe GSL::World::View do
  before do
    @object = GSL::World::View.new
  end
end
