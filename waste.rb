require 'gsl'

waste = rules_for "Industrial Waste", "Jurgen Strohm" do |game|
  game.for_players 3..4
  
  game.contents do |list|
    list.has 50, :gold, "yellow cube"
  end
end

waste.play(4);