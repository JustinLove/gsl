require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/game}

describe "Industrial Waste" do
  it "runs" do
    GSL::Game.new(file("waste.rb"), file("waste_hint.rb"))
  end
end
