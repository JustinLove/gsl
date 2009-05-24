require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/plan}

class GSL::Plan
  include Tattler
end

describe GSL::Plan do
  
end
