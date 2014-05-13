Grue.Supporter = Supporter = Grue.Thing.mutate("Supporter", ->
  @contents = new Grue.Bag()
  return
)
Supporter::add = (item) ->
  @contents.push item
  item.parent = this
  return

Supporter::remove = (item) ->
  @contents.remove item
  item.parent = null
  return
