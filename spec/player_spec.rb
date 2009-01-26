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
    
    it "executes through a filter" do
      context = nil
      @object.execute(:blarg) do |a|
        a.should == :blarg
        context = self
      end
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
    
    describe "chooses" do
      before do
        @object.class.make_resource(:keys)
        @object.set_to 1, :keys
        @good = lambda{gain 1, :keys}
        @bad = lambda{pay 3, :keys}
      end
      
      describe "(internals)" do
        it "what_if" do
          @object.what_if(@good).legal?.should be_true
          @object.what_if(@bad).legal?.should be_false
        end
        
        it "what_if_without" do
          @object.what_if_without(@good).legal?.should be_true
          @object.what_if_without(@bad).legal?.should be_false
        end
        
        it "rate_state" do
          @object.rate_state(@object.what_if(@good).state).should > 
            @object.rate_state(@object.what_if(@bad).state)
        end
        
        it "rates actions" do
          @object.rate(@good).rating.should > @object.rate(@bad).rating
        end
        
        it "best_rated" do
          g = @object.best_rated([@good, @bad])
          g.what.should == @good
          g.legal?.should be_true
          g.rating.should_not be_nil
          g = @object.best_rated([@bad, @good])
          g.what.should == @good
        end

        it "best_rated nothing" do
          @object.best_rated([]).should be_nil
        end
      end
      
      it "from an array" do
        @object.choose([@bad, @good, @bad])
        @object.keys.value.should == 2
      end
      
      it "from a hash" do
        @object.choose(:fee => @bad, :fie => @good, :fo => @bad)
        @object.keys.value.should == 2
      end
      
      it "from a resource" do
        @object.class.make_resource(:choices)
        @object.set_to [@bad, @good, @bad], :choices
        @object.choose(:choices)
        @object.keys.value.should == 2
      end
      
      it "through a filter" do
        @object.choose([@bad, @good, @bad]) do |choice|
          execute choice
          execute choice
        end
        @object.keys.value.should == 3
      end
      
      it "from nothing" do
        @object.choose([]).should be_nil
      end

      describe "takes" do
        before do
          @game.class.make_resource(:pebbles)
          @game.set_to [@bad, @good, @bad], :pebbles
        end
        
        it "something" do
          @object.take(:pebbles)
          @object.keys.value.should == 2
          @game.pebbles.value.should_not include(@good)
        end
        
        it "through a filter" do
          @object.take(:pebbles) do |it|
            execute it
            execute it
          end
          @object.keys.value.should == 3
          @game.pebbles.value.should_not include(@good)
        end
        
        it "nothing" do
          @object.take([]).should be_nil
        end
      end
      
      describe "uses" do
        before do
          @game.class.make_components(:twigs, [:good])
          GSL::Component.define_action(:good, @good)
          @object.class.make_resource(:twigs)
          @object.class.make_resource(:twigs_discard)
          @object.set_to [GSL::Component.new(:good)], :twigs
          @object.set_to [], :twigs_discard
        end
        
        it "from nowhere" do
          @object.use(@object.draw(:twigs))
          @object.keys.value.should == 2
        end

        it "from a resource" do
          @object.use(:good, @object.twigs)
          @object.keys.value.should == 2
        end
      end
    end
  end
end
