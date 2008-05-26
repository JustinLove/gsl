require 'gsl'

roman = rules_for "Gregs Roman Game" do |game|
  game.for_players 3..5
  
  game.has_components do |list|
    list.has 50, :gold, "yellow cube"
    list.has 50, :person, "white cube"
    list.has 20, :senator, "custom tile"
    list.has 16, :privlige, "custom tile"
    list.has 20, :gate, "tile"
    list.has 20, :farm, "tile"
    list.has 20, :mine, "tile"
    list.has 10, :dock, "tile"
    list.has 10, :colusemum, "tile"
    list.has 10, :forum, "tile"
    list.has 10, :market, "tile"
    list.has 10, :monument, "tile"
    list.has 10, :expansion, "tile"
    list.has 10, :temple, "tile"
    list.players_have 1, :pawn, "pawn"
    list.players_have 1, :score, "cube"
    
    senators_give = [:gate, :farm, :mine, :special, :expansion, :temple, :monument]
    
    list.custom :senator do |senators|
      senators.each do |s|
        s.cost :gold => rand(4)+1
        s.cost :people => rand(4)+1
        s.benefit :influence => s.gold + s.people - 1
        s.benefit :city => [senators_give[rand(senators_give.length)]]
        def s.to_s 
          "#{@people},#{@gold} => #{@influence},#{@gives}" 
        end
      end
    end
    
    list.custom :privlige do |privs|
      privs[0,2] = "Double Buy"
      privs[2,2] = "Move Back"
      privs[4,2] = "Extra gold"
      privs[6,2] = "Extra People"
      
      privs[8,2] = "Don't pay gold"
      privs[10,2] = "Double Special"
      privs[12,2] = "Speical 1"
      privs[14,2] = "Special 2"
    end
  end
  
  game.has_board do |layout|
    layout.has :senate => [
      Array.new(2),
      Array.new(5),
      Array.new(6),
      Array.new(7)
    ]
    layout.has :turn_order => Array.new(game.player_range.max)
  end
  
  game.game_setup do
    game.players.each do |player|
      player.gain :gold, 6
      player.gain :people, 6
    end
  end
  
  game.has_rounds 4

  game.every_round do |round|
    round.phase_order [:setup, :execute, :finish]
    round.to_setup do
      p '-----New Round----'
      game.board.senate.each do |row|
        game.components.assign_random(:senator, row)
      end
      game.players.each do |player|
        city = player.fetch(:city)
        player.gain :gold, city.find_all {|b| b == :farm}.length + 2
        player.gain :people, city.find_all {|b| b == :gate}.length + 2
        player.reset :influence, 0
        player.done = false
      end
    end
    round.to_execute do
      while (game.players.any? do |player| !player.done end)
        game.players.each do |player| player.take_turn end
      end
    end
    round.to_finish do
    end
  end
  
  game.players_have do |player|
    player.has :gold
    player.has :people
    player.has :score
    player.has :influence
    player.has :city, []
  end
  
  game.players_can do |player|
    player.can :buy_senator do |actor|
      all = game.board.all(:senate)
      #p all.length
      affordable = all.find_all {|s| s.afford_by(actor)}
      #p affordable.length
      senator = affordable.random
      #p senator
      if (senator)
        actor.purchase senator
        game.board.remove :senate, senator
        true
      else
        false
      end
    end
    player.can :pass do |actor|
      actor.done = true
      true
    end
  end
end

roman.play(4);