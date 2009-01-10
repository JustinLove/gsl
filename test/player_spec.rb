require File.join(File.dirname(__FILE__), 'test_helper')
libs %w{player game}

class GSL::Player
  include Tattler
end

describe GSL::Player do
  before do
    @game = GSL::Game.new()
    @game.create_players(3)
    @object = @game.players.first
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
  
  it "picks a color" do
    @object.pick_color :red, :green, :blue
    [:red, :green, :blue].should include(@object.color)
  end
  
  it "doesn't duplicate colors" do
    @game.players.each do |player|
      player.pick_color :red, :green, :blue
    end
    @game.players.map {|player| player.color.to_s}.sort.
      should == ['red', 'green', 'blue'].sort
  end
  
end
