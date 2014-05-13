Grue.Container = Container = Grue.Thing.mutate("Container", ->
  @contents = new Grue.Bag()
  @open = false
  @preposition = "Inside: "
  @proxy "contents", ->
    return @contents  if @open
    new Grue.Bag()

  @cue "open", ->
    @open = true
    @say "Opened."
    return

  @cue "close", ->
    @open = false
    @say "Closed."
    return

  @cue "contents", ->
    contents = @get("contents")
    return ""  unless contents.length
    response = @world.format.as("list",
      label: @preposition
      data: contents.mapGet("name")
    )
    response

  @cue "look", ->
    @say @world.format.text(@description, @ask("contents"))
    return

  return
)
Container::add = (item) ->
  @contents.push item
  item.parent = this
  return

Container::remove = (item) ->
  @contents.remove item
  item.parent = null
  return
