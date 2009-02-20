require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/game}

describe "Industrial Waste" do
  it "runs" do
    begin
      GSL::Game.new(file "waste.rb")
    rescue GSL::Resource::Insufficient
      pending "don't let it run out of money"
    end
  end
end
