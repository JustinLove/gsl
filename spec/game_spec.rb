require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{game}

class GSL::Game
  include Tattler
end

describe GSL::Game do
  before do
    @object = GSL::Game.new
  end
  
  it_should_behave_like "well behaved objects"
  
  it "takes a title" do
    @object.title "Game Spec"
    @object.title.should == "Game Spec"
  end                 
  
  it "takes an author" do
    @object.author "Justin Love"
    @object.author.should == "Justin Love"
  end
  
  it "takes a number of players" do
    @object.number_of_players 3..4
    @object.number_of_players.should == (3..4)
  end
  
  it "defines common components" do
    @object.common_components :cubes => 5
    @object.cv.components.keys.should include(:cubes)
  end

  it "defines player components" do
    @object.player_components :pyramids => 5
    GSL::Player.cv.components.keys.should include(:pyramids)
  end
  
  it "defines common resources" do
    @object.common_resource :nuts
    @object.cv.resources.should include(:nuts)
  end
  
  it "defines player resources" do
    @object.player_resource :seeds
    GSL::Player.cv.resources.should include(:seeds)
  end
  
  it "defines steps with to" do
    @object.to :dig do; :dirt; end
    @object.dig.should == :dirt
  end

  it "defines steps with every" do
    @object.every :full_moon do; :howl; end
    @object.full_moon.should == :howl
  end
  
  it "defines steps with at_any_time" do
    @object.at_any_time :scream do; :yell; end
    GSL::Player.new(@game).scream.should == :yell
  end
  
  it "check context" do
    @object.during(:grunt).should be_false
    @object.to :grunt do
      during(:grunt).should be_true
      during(:groan).should be_false
    end
    @object.during(:grunt).should be_false
  end
  
  it "asserts context" do
    @object.to :groan do
      lambda{only_during(:groan)}.should_not raise_error
      lambda{only_during(:grunt)}.should raise_error
    end
  end
  
  it "defines cards" do
    @object.card :joker do; :wild; end
    GSL::Component.new(:joker).to_proc.call.should == :wild
  end
  
  describe "with cards" do
    before do
      @object.common_components :playing_cards => {:jack => 4, :queen => 4, :king => 4}
      @object.common_resource :playing_cards
      @cards = [:jack, :queen, :king]
    end
    
    it "draws a card" do
      @cards.should include(@object.draw(:playing_cards).name)
    end
    
    it "shuffles" do
      same = 0
      different = 0
      3.times do
        names = @object.playing_cards.names
        @object.shuffle(:playing_cards)
        if (names == @object.playing_cards.names)
          same += 1
        else
          different += 1
        end
      end
      different.should > 0
    end
    
    it "reshuffles" do
      old_count = @object.playing_cards.count
      old_count.times do
        @object.draw(:playing_cards).discard
      end
      @object.playing_cards.count.should == 0
      @object.reshuffle
      @object.playing_cards.count.should == old_count
    end
  end
end