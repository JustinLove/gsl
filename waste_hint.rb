resource_hints({
  :money => 0.5,
  :loans => -1,
  :co_workers => -1,
  :rationalization => -1,
  :materials_required => -1,
  :waste_reduction => -1,
  :waste_disposal => -1,
})

hints({
  action('labor'){co_workers.value < rationalization.value} => -20
})
