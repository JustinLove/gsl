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
  
  it "defines cards" do
    @object.card :joker do; :wild; end
    GSL::Component.new(:joker).to_proc.call.should == :wild
  end
end