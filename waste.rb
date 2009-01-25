title "Industrial Waste"
author "Jurgon Strohm"
number_of_players 3..4

common_components :action_cards => {
    :order => 9,
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
  end
  starting_player_is :youngest
end

at_any_time :take_a_loan do
  gain 10, :money
  gain 10, :loans
end

at_any_time :report do
  "%%%% #{self.to_s} " +
    "#{co_workers.value}/#{rationalization.value}p " +
    "#{raw_materials.value}/#{materials_required.value}m " +
    "#{waste_disposal.value}(#{waste_disposal.section})/#{waste_reduction.value}w " +
    "$#{money.value}(-#{loans.value}) +#{growth.value} " +
    "#{held_cards.count}"
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
    case value
    when 0..8 then :green
    when 9..12 then :yellow
    when 13..16 then :red
    else
      Error "impossible section"
    end
  end
end
player_resource :raw_materials
player_resource :held_cards, 0..4, :discard_to => :action_cards_discard

#hidden trackable information ;^)
player_resource :money
player_resource :loans

to :play do
  prepare
  round until game_over?
  accident
  score
end

every :round do
  puts "before " + action_cards.to_s
  lay_out_card_combinations
  puts "left " + action_cards.to_s
  choose_card_combinations
  checkpoint
  play_the_cards
  puts "after " + action_cards.to_s
  pay_basic_costs
  change_the_starting_player
  #each_player {puts report}
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
        else
          if names(pile).include?(card.name)
            discard card; reshuffle; draw;
          else
            card
          end
        end
      end
    end
  end
end

to :choose_card_combinations do
  each_player do
    take(:combinations) {|choice| gain(choice, :held_cards);}
  end
  combinations.each do |pile|
    note "discard leftover #{pile.to_s}"
    pile.each do |card|
      discard card
    end
  end
end

to :play_the_cards do
  each_player_until_pass do
    acted = choose :held_cards do |card|
      case judge(card)
      when :good:
        use card
        Acted
      when :bad:
        if held_cards.count <= 1
          #note "#{self} saves #{card.to_s}"
          Passed
        elsif card.name == :material_sale 
          #note "#{self} forced to use #{card.to_s}"
          use card
          Acted
        else
          note "#{self} discards #{card.to_s}"
          discard card
          Acted
        end
      end
    end
    note report
    checkpoint
    acted
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
  pay materials_required, :raw_materials
  must_gain waste_reduction, :waste_disposal
  gain growth, :money
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
  choose [:rationalization, :materials_required, :waste_reduction] do |choice|
    lose 1, choice
  end
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
  choose :repay_loan => Action{pay(10, :money); must_lose(10, :loans)},
    :double => Action{
      must_have {held_cards.count > 0}
      choose :held_cards do |card|
        use_twice = Action{execute card; use card;}
        case card.name
        when :material_sale: use card;
        when :growth: use_twice.call;
        when :hiring_firing: use_twice.call;
        when :waste_disposal: use_twice.call;
        when :waste_removal: use_twice.call;
        when :order: gain(5, :money) if use(card);
        else raise NotAllowed, "can't double #{card}"
        end
      end
    }
end

to :pay_basic_costs do
  each_player do
    pay co_workers, :money
  end
end

to :change_the_starting_player do
  p "----- rotate"
  players.rotate
  if action_cards.discards.include? :accident
    reshuffle :action_cards
  end
end

to :score do
  each_player do
    score = growth.value
    [:rationalization, :materials_required, :waste_reduction].each do |tech|
      score += triangle(6 - resource(tech).value)
    end
    score += money.value/2
    score -= loans
    tiebreaker = money.value
    puts report
    puts score
  end
end
