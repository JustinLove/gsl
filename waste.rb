title "Industrial Waste"
author "Jurgon Strohm"
number_of_players 3..4

common_components :action_cards => {
    :order => 4,
    :material_sale => 8,
    :growth => 8,
    :innovation => 7,
    :waste_disposal => 7,
    :advisor => 4,
    :hiring_firing => 4,
    :waste_removal => 3,
    :bribery => 2,
    :accident => 1,
  },
  :loan_cards => {
    :'-10' => 8,
    :'-20' => 4,
  },
  :EURO_bank_notes => {
    :'1' => 12,
    :'2' => 12,
    :'5' => 12,
    :'10' => 12,
    :'20' => 12,
  },
  :game_board => 1,
  :EURO => 1,
  :raw_materials => 50

player_components :cylinders => 4,
  :factory => 1,
  :company_mat => 1

to :prepare do
  # this doesn't collect all cards from a previous run...
  reshuffle :action_cards
  each_player do
    pick_color :blue, :yellow, :green, :red
    set_to 5, :rationalization, :materials_required, :waste_reduction
    set_to 0, :waste_disposal
    set_to 5, :co_workers
    set_to 14, :growth
    set_to 0, :loans
    set_to 15, :money
    set_to 5, :raw_materials
    set_to [], :held_cards
    set_to [], :saved_cards
  end
  starting_player_is :youngest
end

at_any_time :take_a_loan do
  gain 10, :money
  gain -10, :loans
end

at_any_time :report do
  "#{self.to_s} " +
    "#{co_workers.value}/#{rationalization.value}p " +
    "#{raw_materials.value}/#{materials_required.value}m " +
    "#{waste_disposal.value}(#{waste_disposal.section})/#{waste_reduction.value}w " +
    "$#{money.value}(#{loans.value}) +#{growth.value} " +
    "#{held_cards.count}(#{saved_cards.count})"
end



#game board
player_resource :growth, 14..20
player_resource :co_workers, 1..5

#company mat
# scoring value...?
player_resource :rationalization, 1..5
player_resource :materials_required, 1..5
player_resource :waste_reduction, 1..5
player_resource :waste_disposal, 0..16 do
  def section
    case @value
    when 0..8 then :green
    when 9..12 then :yellow
    when 13..16 then :red
    else
      Error "impossible section"
    end
  end
end
player_resource :raw_materials
player_resource :held_cards, 0..4
player_resource :saved_cards, 0..1

#hidden trackable information ;^)
player_resource :money, 0..Infinity
player_resource :loans, -Infinity..0

to :play do
  prepare
  round until game_over?
  accident
  score
end

every :round do
  lay_out_card_combinations
  choose_card_combinations
  play_the_cards
  pay_basic_costs
  change_the_starting_player
end

every :accident do
  p "Accident!"
  each_player do
    case waste_disposal.section
    when :red: pay 10, :money; lose(2, :growth) unless use(:bribery, held_cards);
    when :yellow: pay 5, :money; lose(1, :growth) unless use(:bribery, held_cards);
    end
    puts report
  end
end

common_resource :combinations

to :lay_out_card_combinations do
  #p action_cards.to_s
  set_to (number_playing? + 1).piles, :combinations
  3.times do
    combinations.each do |pile|
      pile << draw(:action_cards) do |card|
        case (card && card.name) || Empty
        when Empty: reshuffle; draw;
        when :accident: accident; discard card; reshuffle; draw;
        else card
        end
      end
    end
  end
end

to :choose_card_combinations do
  each_player do
    gain choose_best(:combinations), :held_cards
    if saved_cards.count >= 1
      gain [saved_cards.draw], :held_cards
    end
  end
  combinations.each do |pile|
    pile.each do |card|
      discard card
    end
  end
end

to :play_the_cards do
  each_player_until_pass do
     choose_best :held_cards,
       :good => Action{|card| use card},
       :bad => Action{|card|
         if held_cards.count < 1
           gain [card], :saved_cards
           Passed
         elsif card.name == :material_sale 
           use card
           Acted
         else
           puts "#{self} discards #{card.to_s}"
           card.discard
           Acted
         end
       }
  end
end

card :material_sale do
  auction = materials_required.value
  during :advisor do auction *= 2 end
  $bid = 0
  $bidder = self
  each_player_from_left do
    bid = auction + (materials_required - raw_materials) + (-1..2).random
    bid = [bid, money].min
    if (bid > $bid)
      $bid = bid
      $bidder = self
    end
  end
  $bidder.gain auction, :raw_materials
  $bidder.pay $bid, :money
  if ($bidder != self)
    gain $bid, :money
  end
end

card :order do
  must_have {co_workers >= rationalization}
  pay materials_required.value, :raw_materials
  must_gain waste_reduction.value, :waste_disposal
  gain growth.value, :money
end

card :growth do
  gain 1, :growth
  if growth >= 20
    game_over!
  end
end

card :hiring_firing do
  if (co_workers > rationalization)
    lose 1, :co_workers
  end
  # +1?
  #taking strategic advantage of this without speculative execution is tough...
end

card :innovation do
  pay 5, :money
  lose 1, [:rationalization, :materials_required, :waste_reduction].random
end

card :waste_disposal do
  lose 3, :waste_disposal
end

card :waste_removal do
  if (waste_disposal >= 1)
    lose 1, :waste_disposal
    other_players {gain 1, :waste_disposal}
  end
end

card :bribery do
  only_during :accident
  pay 1, :money
end

card :advisor do
  choose :repay_loan => Action{pay(10, :money); gain(10, :loans)},
    :double => Action do
      must_have {held_cards.count > 0}
      use_twice = Action{use card; use card;}
      choose :held_cards do |card|
        case card.name
        when :material_sale: use card;
        when :growth: use_twice.call;
        when :hiring_firing: use_twice.call;
        when :waste_disposal: use_twice.call;
        when :waste_removal: use_twice.call;
        when :order: gain(5, :money) if use(card);
        else Error("can't double #{card}") 
        end
      end
    end
end

=begin

pay the basic costs: each player pays money = co-workers

change starting player:
  - pass starting-player to left
  - if accident was drawn, reshuffle cards
  - check for game-over flag

Game over:
  - process accident as above

Scoring:
  - +growth
  - +[rationalization, materials-required, waste-reduction]
  - +money/2 round down
  - +loans (negative)
  - tiebreaker: money

=end