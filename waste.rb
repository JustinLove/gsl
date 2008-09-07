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

preparation do
  shuffle :action_cards
  each_player do
    pick_color :blue, :yellow, :green, :red
    set_to 5, :rationalization, :materials_required, :waste_reduction
    set_to 0, :stored_waste
    set_to 5, :co_workers
    set_to 14, :growth
    set_to 0, :loans
    set_to 15, :money
    set_to 5, :raw_materials
  end
  starting_player_is :youngest
end

=begin

Preparation:
  - the oldest player is the bank
  - shuffle action-cards
  - each player:
    - set rationalization, materials-required, and waste-reduction 5
    - set stored-waste to 0
    - set co-workers to 5
    - set growth to 14
    - set loans to 0
    - set money 15
    - set raw-materials 5
  - the youngest player is the dealer
  - the dealer is the starting player
  - the starting player takes the EURO

Playing the game:

Loans:
At any time, a player may take-a-loan:
   - take 10 million
   - take -10 loan

Game board:
Growth (14-20):
  - money earned for each order
  - victory points

Co-workers (1-5): 
  - required level of rationalization
  - money paid by each player at the end of each round

The company mat (each player):
Building:
  - rationalization (1-5)
  - materials-required (1-5)
  - waste-reduction (1-5)
  - waste-disposal (0-16):
    - green (0-8)
    - yellow (9-12)
    - red (13-16)
  - raw-materials

[rationalization, materials-required, waste-reduction]: victory points
  - 5: 1
  - 4: 3
  - 3: 6
  - 2: 10
  - 1: 15

Playing a round:
   - lay out card combinations
   - choose card combinations
   - play the cards
   - pay basic costs
   - change the starting player

lay out card combinations: 3 time in players+1 combinations, dealer draws one card.
  - combination-duplicates: discard and redraw.
  - out: reshuffle
  - draw accident: discard and redraw.
    - waste-disposal green: n/a
    - waste-disposal yellow: -5 million, -1 growth (play bribery: -0 growth)
    - waste-disposal red: -10 million, -2 growth (play bribery: -0 growth)

choose card combinations:
  - each player clockwise: move one combination to held-cards
  - discard leftover combinations

play the cards: each player clockwise repeating, choose one:
  - play a card (and then discard it)
  - discard a card: material-sale: disallow discard
  - save a card (last card only)

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