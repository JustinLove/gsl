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
player_resource :held_cards, 0..5 #actually players + 1
player_resource :saved_cards, 0..1

#hidden trackable information ;^)
player_resource :money

to :play do
  prepare
  round until game_over?
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
  each_player do
    case waste_disposal.section
    when :red: lose 10, :money; use(:bribary) || lose(2, :growth);
    when :yellow: lose 5, :money; use(:bribary) || lose(1, :growth);
    end
  end
end

common_resource :combinations

to :lay_out_card_combinations do
  set_to (number_playing? + 1).piles, :combinations
  3.times do
    combinations.value.each do |pile|
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
    if saved_cards.value.count > 1
      gain saved_cards.draw, :held_cards
    end
  end
  combinations.value.each do |pile|
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
         if held_cards.value.count < 1
           gain card, :saved_cards
           Passed
         elsif card.name == :material_sale 
           use card
           Acted
         else
           card.discard
           Acted
         end
       }
  end
end

common_resource :auction

card :material_sale do
  set_to materials_required.value, :auction
  $bid = 0
  $bidder = self
  each_player_from_left do
    bid = auction.value + (materials_required.value - raw_materials.value)
    if (bid > $bid)
      $bid = bid
      $bidder = self
    end
  end
  $bidder.gain lose(auction.value, :auction), :raw_materials
  $bidder.lose $bid, :money
  if ($bidder != self)
    gain $bid, :money
  end
end

=begin

Card: material-sale:
  - player auctions M raw materials; M = player's materials-required
  - players bid in relative-left-clockwise-once
     - buyer is other-player: pay to seller
     - buyer is seller: pay to bank

Card: order:
  - check co-workers >= rationalization
  - spend raw-materials = materials-required
  - gain waste-disposal = waste-reduction (overflow: disallow action)
  - gain money = growth

Card: growth: growth + 1.  If growth = 20, set game-over flag

Card: hiring/firing: co-workers +/- 1

Card: innovation:
  - spend 5 million
  - choose one [rationalization, materials-required, waste-reduction] - 1

Card: waste disposal: waste-disposal - 3

Card: waste removal: 
  - w = min(active player waste-disposal, 1)
  - active player waste-disposal - w
  - other players waste-disposal - w

Card: bribery:
  - play only during accident
  - spend 1 million
  - reduce growth loss to 0

Card: advisor:
  - repay-loan: -10 money, +10 loans
  - sell-materials: sell twice as many
  - growth: perform-twice
  - hiring/firing; perform-twice
  - waste disposal: perform-twice
  - waste removal: perform-twice
  - order: money + 5

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