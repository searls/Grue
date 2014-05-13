Grue.Player = Player = Grue.Thing.mutate("Player", ->
  @inventory = new Grue.Container(@world)
  @inventory.preposition = "In your inventory:"
  @inventory.open = true
  return
)
