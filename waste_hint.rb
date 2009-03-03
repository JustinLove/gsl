resource_hints({
  :money => 0.5,
  :loans => -1,
  :co_workers => -1,
  :rationalization => -3,
  :materials_required => -3,
  :waste_reduction => -3,
  :waste_disposal => -1,
})

hint {-20 if (co_workers.value < rationalization.value)}
