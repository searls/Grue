Grue.Room = Room = Grue.Thing.mutate("Room", ->
  @regions = new Grue.Bag()
  @contents = new Grue.Bag()
  @cue "contents", ->
    contents = @get("contents").query("type!=Scenery")
    if contents.length
      return @world.format.as("list",
        label: "In this area:"
        data: contents.mapGet("name")
      )
    ""

  @cue "look", ->
    @say @world.format.text(@description, @ask("contents"))
    return

  @cue "go", (event) ->
    compass =
      west: "w"
      north: "n"
      south: "s"
      east: "e"
      up: "u"
      down: "d"
      inside: "in"
      outside: "out"

    direction = event.direction
    direction = compass[direction]  if compass[direction]
    portal = @get(direction)
    unless portal
      @say "You can't go that way."
    else
      @world.currentRoom = portal
      portal.ask "look"  if portal.check("look")
    return

  return
)
Room::add = (item) ->
  @contents.push item
  item.parent = this
  return

Room::remove = (item) ->
  @contents.remove item
  item.parent = null
  return

Room::query = (selector) ->
  @contents.query selector

#  Rooms have a "regions" Bag that you can use to share rules across a zone.
#  Regions are not actually containers--they're just Things that respond to
#  ask() with false if the command is being intercepted. Any rules that can be
#  preempted by a region, such as "look," should call World.currentRoom.check()
#  the same way that they would call ask() on a target object first.
Room::check = (key, event) ->
  cancelled = @regions.reduce((memo, region) ->
    region.ask(key, event) isnt false and memo
  , true)
  cancelled
