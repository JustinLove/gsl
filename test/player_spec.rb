require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{player game}

class GSL::Player
  include Tattler
end

describe GSL::Player do
  before do
    @game = GSL::Game.new()
    @object = GSL::Player.new(@game)
  end

  it_should_behave_like "well behaved objects"
  
  describe "Player class" do
    it "should define any time actions" do
      GSL::Player.at_any_time(:test, lambda {$ran = true})
      $ran = false
      @object.test
      $ran.should be_true
    end
  end
end
