require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/player gsl/game}

class GSL::Player
  include Tattler
  ygg_accessor :passed
  module Common
    PLANS = [GSL::Plan::Cached]
  end
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
  
  it "versions pass" do
    @object.world.branch {
      @object.pass
      @object.passed.should be_true
    }
    @object.passed.should_not be_true
  end
  
  it "calcualtes a score" do
    @object.score do
      plus 10
      minus 2
    end
    @object.score.should == 8
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
    it "makes actions" do
      act = @object.action(:blarg) {}
      act.to_proc.should_not be_nil
      act.name.should == :blarg
    end
    
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
    
    it "doesn't catch other exceptions" do
      lambda {GSL::Future.new(@object, lambda{raise "hell"}).force}.should raise_error("hell")
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
      
      it "future is impotent" do
        GSL::Future.new(@object, @action)
        @object.marbles.value.should == 5
      end
      
      it "score is impotent" do
        @object.score do
          gain 2, :marbles
        end
        @object.marbles.value.should == 5
      end
    end
    
    describe "chooses" do
      before do
        @object.class.make_resource(:keys)
        @object.resource_hints(:keys => 1)
        @game.each_player {set_to 1, :keys}
        @good = lambda{gain 1, :keys}
        @bad = lambda{pay 3, :keys}
        @better = lambda{gain 5, :keys}
      end
      
      describe "(internals)" do
        it "rate_state" do
          @object.rate_state(GSL::Future.new(@object, @good).state).should > 
            @object.rate_state(GSL::Future.new(@object, @bad).state)
        end
        
        it "rate_state with scoring function" do
          class GSL::Game
            def score
              each_player do
                score do
                  plus keys.value
                end
              end
            end
          end
          @object.rate_state(GSL::Future.new(@object, @better).state).should > 
            @object.rate_state(GSL::Future.new(@object, @good).state)
          class GSL::Game
            remove_method :score
          end
        end
        
        it "best_rated" do
          g = @object.choose_best([@good, @bad])
          g.what.should == @good
          g.legal?.should be_true
          g.rating.should_not be_nil
          g = @object.choose_best([@bad, @good])
          g.what.should == @good
        end

        it "commits legal acts" do
          @object.use(@good)
          @object.keys.value.should == 2
        end

        it "commits illegal acts" do
          lambda {@object.use(@bad)}.should raise_error(GSL::Game::Illegal)
        end
        
        it "poisons the well" do
          bad = @bad
          lambda {@object.use(lambda{
            use(bad)
          })}.should raise_error(GSL::Game::Illegal)
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
      
      it "from a range" do
        @object.choose(1..5) {|n| gain n, :keys}
        @object.keys.value.should > 1
      end
      
      it "from a number" do
        @object.choose(5) {|n| gain n, :keys}
        @object.keys.value.should > 1
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

      it "returns a value" do
        @object.choose([@good]).should == @good
      end
      
      it "considers uncommited choices" do
        @object.consider([@good, @bad]).should == @good
        @object.keys.value.should == 1
      end
      
      it "doesn't handles recursive choice" do
        @object.class.make_resource(:doors)
        @object.resource_hints(:doors => -1, :keys => 0.5)
        @game.each_player {set_to 0, :doors}
        class GSL::Game
          def score
            each_player do
              score do
                plus(keys.value / 2)
                minus doors.value
              end
            end
          end
        end
        begin
          lambda {
            @object.choose :one => lambda {
              choose :loan => lambda {gain 10, :keys; gain 10, :doors},
                :not => lambda {}
              pay 5, :keys
            }
            @object.doors.value.should == 10
          }.should raise_error
        ensure
          class GSL::Game
            remove_method :score
          end
        end
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

        it "returns a value" do
          @object.take(:pebbles).should == @good
        end
      end
      
      describe "uses" do
        before do
          @game.class.make_components(:twigs, [:good])
          GSL::Component.define_action(:good, @good)
          @object.class.make_resource(:twigs)
          @object.class.make_resource(:twigs_discard)
          @object.set_to [GSL::Component.new(:good, :good, @game.world)], :twigs
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
