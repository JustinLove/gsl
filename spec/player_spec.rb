require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{player game}

class GSL::Player
  include Tattler
end

describe GSL::Player do
  before do
    @game = GSL::Game.new()
    @game.create_players(3)
    @object = @game.players.first
    @colors = [:red, :green, :blue]
    @sort_colors = @colors.map {|c| c.to_s}.sort
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
    @object.pick_color(*@colors)
    @colors.should include(@object.color)
  end
  
  describe "with assigned colors" do
    before do
      @game.players.each do |player|
        player.pick_color(*@colors)
      end
      @other_colors = @colors - [@object.color]
      @sort_other_colors = @other_colors.map {|c| c.to_s}.sort
    end

    it "doesn't duplicate colors" do
      @game.players.map {|player| player.color.to_s}.sort.
        should == @sort_colors
    end
    
    it "iterates other players" do
      seen = []
      @object.other_players do |player|
        player.should_not == @object
        seen << player.color.to_s
      end
      seen.sort.should == @sort_other_colors
    end
    
    it "iterates each player from left" do
      seen = []
      @object.each_player_from_left do |player|
        seen << player.color.to_s
      end
      seen.last.should == @object.color.to_s
      seen.sort.should == @sort_colors
    end
  end
  
  describe "common" do
    it "executes procs" do
      context = nil
      @object.execute(lambda{context = self})
      context.should == @object
    end

    it "executes components" do
      context = nil
      card = GSL::Component.new(:card)
      GSL::Component.define_action(:card, lambda{context = self})
      @object.execute(card)
      context.should == @object
    end
    
    it "judges good actions" do
      @object.judge(lambda{}).should == :good
    end

    it "judges bad actions" do
      @object.judge(lambda{raise GSL::GamePlayException}).should == :bad
    end

    it "doesn't catch other exceptions" do
      lambda {@object.judge(lambda{raise "hell"})}.should raise_error("hell")
    end
    
    describe "side effects" do
      before do
        @object.class.make_resource(:marbles)
        @object.set_to 5, :marbles
        @action = lambda {pay 3, :marbles}
      end
      
      it "execute has effects" do
        @object.execute(@action)
        @object.marbles.value.should == 2
      end
      
      it "judge is idempotent" do
        @object.judge(@action)
        @object.marbles.value.should == 5
      end
    end
  end
end
