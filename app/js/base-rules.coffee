#  To match Zork, we need:
#    north/northeast/east/southeast/south/southwest/west/northwest
#    up/down
#    look
#    save/restore (?)
#    restart
#    verbose
#    score
#    diagnostic
#
#    take [all]
#    throw X at Y
#    open X
#    read X
#    drop X
#    put X in Y
#    turn X with Y
#    turn on X
#    turn off X
#    move X
#    attack X with Y
#    examine X
#    inventory
#    eat X
#    shout
#    close X
#    tie X to Y
#    kill self with X
#
#
Grue.BaseRules = init: (world) ->
  world.parser.addRule /(look|examine|describe)( at )*([\w\s]+)*/i, (match) ->
    object = match[3]
    if object
      world.askLocal "look", match[3]
    else world.currentRoom.ask "look"  if world.currentRoom.check("look")
    return

  world.parser.addRule /(open|close) ([\s\w]+)/i, (match) ->
    verb = match[1]
    awake = world.getLocal(false, match[2])
    if awake
      awake.ask verb
    else
      world.print "You can't open that."
    return

  world.parser.addRule /read ([\w\s]+\w)/, (match) ->
    awake = world.getLocal(false, match[1])
    if awake
      awake.ask "read"
    else
      world.print "I don't think you can read that right now."
    return

  world.parser.addRule "turn :item on", (matches) ->
    awake = world.getLocal(false, matches.item)
    if awake
      awake.ask "activate"
    else
      world.print "Turn what on?"
    return

  world.parser.addRule "turn :item off", (matches) ->
    awake = world.getLocal(false, matches.item)
    if awake
      awake.ask "deactivate"
    else
      world.print "Turn what off?"
    return

  world.parser.addRule /^go ([\w]+)|^(n|north|s|south|e|east|w|west|in|inside|out|outside|up|down)$/i, (match) ->
    world.currentRoom.ask "go",
      direction: match[1] or match[2]

    return

  world.parser.addRule /(take|get|pick up) (\w+)(?: from )*(\w*)/, (match) ->
    portable = world.getLocal("portable=true", match[2])
    return world.print("You can't take that with you.")  unless portable
    portable.parent.remove portable
    portable.ask "taken"
    world.print "Taken."
    @player.inventory.add portable
    return

  world.parser.addRule "drop :item", (match) ->
    dropped = @player.inventory.contents.invoke("nudge", match.item).first()
    return world.print("You don't have any of those.")  unless dropped
    @player.inventory.remove dropped
    @currentRoom.add dropped
    dropped.ask "dropped"
    world.print "Dropped."
    return

  world.parser.addRule /^i(nventory)*$/, ->
    listing = world.player.inventory.ask("contents")
    unless listing
      world.print "You're not carrying anything."
    else
      world.print listing
    return
  return
