require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{random properties resource_user player}

module GSL
  class Game
    extend Properties
    include ResourceUser

    attr_reader :players
    attr_reader :resources

    as_property :title
    as_property :author
    as_property :number_of_players
    as_property :round_limit
    as_proc :time_hint

    def initialize(*files)
      @world = Yggdrasil::World.new
      super()
      @context = []
      @rounds = 0
      @w[:game_over] = false
      @world[:log] = []
      if (files.count > 0)
        files.each do |file|
          # http://www.artima.com/rubycs/articles/ruby_as_dsl.html
          self.instance_eval(File.read(file), file)
        end
        self.go(@number_of_players.random)
      end
    end
  
    def common_components(list)
      list.each do |name,value|
        Game.make_components(name, value)
      end
    end
  
    def player_components(list)
      list.each do |name,value|
        Player.make_components(name, value)
      end
    end
  
    def common_resource(name, range = 0..Infinity, option = {}, &proc)
      Game.make_resource(name, option.merge({:range => range}), &proc)
    end

    def player_resource(name, range = 0..Infinity, option = {}, &proc)
      Player.make_resource(name, option.merge({:range => range}), &proc)
    end
    
    def resource_hints(weights)
      Player.resource_hints(weights)
    end
    
    def hint(&proc)
      Player.hint(&proc)
    end
    
    def create_players(players)
      @players = Array.new(players) {Player.new(self)}
    end

    def go(players)
      puts description
      create_players(players)
      puts "#{@players.size} players"
      play
      puts "#{@w[:game_over]} at round #{@rounds}"
      puts Yggdrasil::State::Tracing.report
    end
  
    def enter(flag)
      @context |= [flag]
    end
  
    def leave(flag)
      @context.delete(flag)
    end

    def during(flag, &proc)
      if (@context.include? flag)
        proc.call if proc
        true
      else
        false
      end
    end
  
    def only_during(flag)
      unless (@context.include? flag)
        Game.illegal :FailedPrecondition, "must be in #{flag}"
      end
    end

    def draw(deck = nil, &filter)
      @deck = deck || @deck
      @resources[@deck].draw(&filter)
    end
  
    def shuffle(deck = nil)
      @deck = deck || @deck
      @resources[@deck].shuffle
    end
  
    def reshuffle(deck = nil)
      @deck = deck || @deck
      @resources[@deck].reshuffle
    end
  
    def discard(card, deck = nil)
      card.discard deck
    end
  
    def number_playing?
      @players.size
    end
  
    def each_player(options = {}, &proc)
      order = [].concat @players
      from = options[:left_of]
      except = options[:except]
      if (from)
        while order.first != from
          order.rotate
        end
        order.rotate
      end
      order.each {|pl| pl.take_turn(&proc) if pl != except}
    end
  
    def each_player_until_pass(&proc)
      active = @players.size
      while active > 0
        active = @players.find_all {|pl| pl.take_turn(&proc) }.count
      end
    end
  
    def starting_player_is(spec)
    end
  
    def at_any_time(name, &proc)
      Player.at_any_time(name, proc)
    end
  
    def to(name, &proc)
      self.class.__send__ :define_method, name do |*args, &block|
        enter name
        result = proc.call(*args, &block)
        leave name
        result
      end
    end
  
    alias every to
  
    def game_over?
      return (@rounds = @rounds + 1) > round_limit || @w[:game_over]
    end
  
    def game_over!
      note 'game over!'
      @w[:game_over] = true
    end
  
    def card(name, &proc)
      Component.define_action name, proc
    end
    
    def checkpoint
      puts note_text
      @world.checkpoint
      @world[:log] = []
    end
    
    def note(what)
      @world[:log] = @world[:log] + [what]
    end
    
    def note_text
      @world[:log].join("\n")
    end
    
    def triangle(x)
      y = 0
      1.upto(x) {|i| y += i}
      y
    end
    
    def simple_fitness
      remaining = (time_hint || round_limit) + 1
      past = @rounds
      total = past + remaining
      if (respond_to? :score)
        score
      end
      each_player do
        fit = 0
        fit = cv.resources.inject(fit) do |sum,res|
          sum + resource(res).fitness #.tap {|x| puts "#{res} #{x}"}
        end
        fit = cv.hints.inject(fit) do |sum,proc|
          sum + (execute(proc) || 0)
        end
        @w[:absolute_fitness] = ((score * past) + (fit * remaining)) / total
        #p "#{self}: #{fit}"
      end
    end
    
    def description
      "#{@title} by #{@author}, #{@number_of_players} players"
    end
  
    def to_s
      "The Game"
    end
    
  end
end
