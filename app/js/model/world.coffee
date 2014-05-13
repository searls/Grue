#And here we are, finally, at the World. You instantiate one (or more) of these
#for your game, and then it provides factory access to the different object
#types, as well as some input and output utility functions.

Grue.World = World = (type = "Development")->
  @things = []
  @player = new Grue.Player(this)
  @asLocal = [@player.inventory]
  @io = new Grue["#{type}Console"]()
  @parser = new Grue.Parser(this, @io)
  @currentRoom = null
  @format = Grue["#{type}Formatter"]
  Grue.BaseRules.init this
  return

World:: =
  Bag: Grue.Bag
  Thing: Grue.Thing.mutate("Thing") # Exposed to create plain "Things"
  mutate: Grue.Thing.mutate #Exposed for mutation
  Room: Grue.Room
  Player: Grue.Player
  Container: Grue.Container
  Supporter: Grue.Supporter
  Scenery: Grue.Scenery
  print: (line) ->
    @io.write line
    return

  considerLocal: (bag) ->
    @asLocal.push bag
    return

  getLocal: (query, target, multiple) ->
    things = new Grue.Bag(@asLocal)
    things.combine @currentRoom.get("contents")  if @currentRoom
    len = things.length
    i = 0

    while i < len
      item = things.at(i)
      things.combine item.get("contents")  if (item instanceof Container and item.open) or item instanceof Supporter
      i++
    things = things.query(query)  if query
    things.nudge = (keyword) ->
      @invoke "nudge", keyword

    if target
      return things.nudge(target)  if multiple
      return things.nudge(target).first()
    things

  query: (selector) ->
    new Grue.Bag(@things).query selector

  askLocal: (verb, object) ->
    allowed = @currentRoom.check(verb)
    return  unless allowed
    awake = @getLocal(false, object)
    awake.ask verb  if awake
    return
