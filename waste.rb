require 'gsl'

waste = rules_for "Industrial Waste", "Jurgen Strohm" do |game|
  game.for_players 3..4
  
  game.contents do |list|
    list.has 53, :action, "card"
    list.has 12, :loan, "card"
    list.has 54, :money, "euros"
    list.players_have 4, :cylinder
    list.players_have 1, :factory
    list.has 1, :board
    list.players_have 1, :mat
    list.has 1, :first, "EURO"
    list.has 50, :material, "barrel"
    
    list.cards :action, {
      :order => 9,
      :material_action => 8,
      :growth => 8,
      :innovation => 7,
      :disposal => 7,
      :advisor => 4,
      :hire => 4,
      :removal => 3,
      :birbary => 2,
      :accident => 1
    }
  end
  
  game.has_board do |layout|
    layout.has :first_player, 0
    layout.has :action_sets, []
    layout.has :game_over, false
  end
  
  game.players_have do |player|
    player.has :workers, 5
    player.has :rationalization, 5
    player.has :materials, 5
    player.has :required_materials, 5
    player.has :waste, 0
    player.has :generated_waste, 5
    player.has :money, 15
    player.has :growth, 14
    player.has :loans, 0
    player.has :actions, []
  end
  
  game.preparation do
    game.components.shuffle :action
  end
  
  game.every_round do |round|
    round.phase_order [:lay_cards, :choose_cards, :play_cards, :pay_costs, :change_starting]
    round.to_lay_cards do
      n = game.players.length + 1
      n.times {game.board.action_stacks[i] = []}
      3.times do
        n.times do |i|
          game.components.action.draw_unique game.board.action_stacks[i] do |card|
            if (card == :accident)
              game.players.each {|p| p.pay_fines}
            end
          end
        end
      end
    end
    round.to_choose_cards do
      game.players.each do |player| player.take_turn :choose_cards end
    end
    round.to_play_cards do
      while (game.players.any? do |player| !player.done end)
        game.players.each do |player| player.take_turn :play_cards end
      end
    end
    round.to_pay_costs do
      game.palyers.each do |player| player.pay_costs end
    end
    round.to_change_starting do
      board.first_player += 1
      if (board.game_over)
        game.over
      end
    end
  end
  
  game.scoring do
    players.each {|player| player.pay_fines; player.scoring; p player}
  end

  game.players_can :choose_cards do |player|
    all = game.board.all(:action)
    #p all.length
    valued = all.
      map {|c| [c, c.valuate_by(actor)]}.
      sort_by {|a| a[1]}
    item = valued.last
    p item.last
    set = item.first
    puts set
    actor.gain :actions, set
    game.board.remove :action, set
  end
  
end

waste.play(4);