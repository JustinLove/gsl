require File.join(File.dirname(__FILE__), '..', 'spec_helper')
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
    GSL::Player.new(@object).scream.should == :yell
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
      @object.class.make_resource :alternate_cards, :initial => []
      @cards = [:jack, :queen, :king]
    end
    
    it "draws a card" do
      @cards.should include(@object.draw(:playing_cards).name)
    end
    
    it "draw remembers the last deck" do
      starting = @object.playing_cards.count
      @object.draw(:playing_cards)
      @object.draw
      @object.playing_cards.count.should == starting - 2
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
    
    it "shuffle remembers the last deck" do
      @object.draw(:playing_cards)
      same = 0
      different = 0
      3.times do
        names = @object.playing_cards.names
        @object.shuffle
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
      @object.reshuffle(:playing_cards)
      @object.playing_cards.count.should == old_count
    end

    it "reshuffle remembers the last deck" do
      old_count = @object.playing_cards.count
      old_count.times do
        @object.draw(:playing_cards).discard
      end
      @object.playing_cards.count.should == 0
      @object.reshuffle
      @object.playing_cards.count.should == old_count
    end
    
    it "discards" do
      @object.discard(@object.draw(:playing_cards))
      @object.playing_cards_discard.length.should == 1
    end
    
    it "discards to an alternate deck" do
      @object.discard(@object.draw(:playing_cards), @object.alternate_cards)
      @object.alternate_cards.length.should == 1
    end
  end

  describe "with players" do
    before do
      @object.create_players(3)
    end
    
    it "iterates players" do
      count = 0
      @object.each_player {count += 1}
      count.should == 3
    end

    it "goes until pass" do
      countdown = 10
      @object.each_player_until_pass {countdown -= 1; pass if (countdown <= 0); }
      countdown.should <= 0
    end

    it "documents that return from block doesn't do what you expect" do
      lambda {
        @object.each_player_until_pass {
          return nil;
        };
      }.should raise_error(LocalJumpError)
    end
  end
  
  it "checkpoints" do
    @object.world[:log] = ["hidy ho"]
    @object.checkpoint
    @object.world[:log].should == []
  end
  
  it "takes notes" do
    @object.note("dear john")
    @object.note_text.should match(/dear john/)
  end
  
  it "calculate triangular numbers" do
    {
      1 => 1,
      2 => 3,
      3 => 6,
      4 => 10,
      5 => 15
    }.each_pair do |k,v|
      @object.triangle(k).should == v
    end
  end
  
  describe "exceptions" do
    it "raise illegal" do
      lambda{GSL::Game.illegal :NotAllowed}.should raise_error(GSL::Game::NotAllowed)
    end

    it "with a message" do
      begin
        GSL::Game.illegal :NotAllowed, "ool"
      rescue GSL::Game::NotAllowed => e
        e.message.should == "ool"
      else
        raise "no exception raised"
      end
    end

    it "with a string" do
      lambda{GSL::Game.illegal "ool"}.should raise_error(GSL::Game::Illegal)
    end

    it "raise error" do
      lambda{GSL::Language.error :Error}.should raise_error(GSL::Language::Error)
    end

  end
end