require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/historian}

class GSL::Historian
  include Tattler
end

describe GSL::Historian do
  before do
    @object = GSL::Historian.new
  end
  
  it_should_behave_like "well behaved objects"
end
