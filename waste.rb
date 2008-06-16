require 'gsl'

waste = rules_for "Industrial Waste", "Jurgen Strohm" do |game|
  game.for_players 3..4
  
  game.contents do |list|
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
    
    list.custom :action do |actions|
      actions.each do |a|
        def a.to_s
          "#{@description}"
        end
      end
    end
  end
  
  game.has_board do |layout|
    layout.has :first_player => 0
    layout.has :action_sets => []
    layout.has :draw_pile => []
    layout.has :game_over => true
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
    game.board.draw_pile.replace game.components.shuffle :action
  end
  
  game.every_round do |round|
    round.phase_order [:lay_cards, :choose_cards, :play_cards, :pay_costs, :change_starting]
    round.to_lay_cards do
      n = game.players.length + 1
      n.times {|i| game.board.action_sets[i] = []}
      3.times do
        n.times do |i|
          game.board.draw_unique :draw_pile, game.board.action_sets[i] do |card|
            if (card == :accident)
              game.players.each {|player| player.pay_fines}
            end
          end
        end
      end
    end
    round.to_choose_cards do
      game.players.each do |player| player.take_turn :choose_cards end
    end
    round.to_play_cards do
      game.players.each do |player| player.done = false end
      while (game.players.any? do |player| !player.done end)
        game.players.each do |player| player.take_turn :play_cards end
      end
    end
    round.to_pay_costs do
      game.players.each do |player| player.pay_costs end
    end
    round.to_change_starting do
      game.board.first_player += 1
      game.over = game.board.game_over
    end
  end
  
  game.scoring do
    game.players.each {|player| player.pay_fines; player.scoring; p player}
  end

  game.players_can do |player|
    player.can :choose_cards do |actor|
      all = game.board.action_sets
      #p all.length
      valued = all.map {|s|
        #p s
        [s, s.map {|c| c.valuate_by(actor)}.reduce(:+) ]
      }.sort_by {|a| a[1]}
      item = valued.last
      #puts item.last
      set = item.first
      #puts set
      actor.gain :actions, set
      game.board.remove :action_sets, set
    end
    player.can :play_cards do |actor|
      actor.done = true
    end
    player.can :pay_costs do |actor|
      actor.spend :money, actor.workers
    end
    player.can :scoring do |actor|
      actor.score = actor.growth
      [:rationalization, :required_materials, :generated_waste].each do |tech|
        actor.score += [15, 10, 6, 3, 1].fetch(actor.__send__(tech) - 1)
      end
      actor.score += actor.money / 2
      actor.score -= actor.loans
    end
    player.can :pay_fines do |actor|
      case actor.waste
      when 0..8
      when 9..12
        actor.lose :growth, 1
        actor.spend :money, 5
      when 12..16
        actor.lose :growth, 2
        actor.spend :money, 10
      end
    end
  end
  
end

waste.play(4);