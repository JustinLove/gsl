round_limit 30

resource_hints({
  :money => 0.5,
  :loans => -1,
  :co_workers => -1,
  :rationalization => -3,
  :materials_required => -3,
  :waste_reduction => -3,
  :waste_disposal => -1,
  :held_cards => 1,
  :growth => 1,
  :raw_materials => 1,
})

hint {-20 if (co_workers.value < rationalization.value)}

time_hint {20 - players.map {|p| p.growth.value || 0}.max}
