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
end