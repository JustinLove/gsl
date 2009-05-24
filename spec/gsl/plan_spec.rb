require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/plan}

class GSL::Plan
  include Tattler
end

describe GSL::Plan do
  before do
    @object = GSL::Plan.new()
  end
  
  it_should_behave_like "well behaved objects"
  
end
