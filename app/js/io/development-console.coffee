Grue.DevelopmentConsole = class
  constructor: ->
    window.$$ = _(@read).bind(this)


  attach: -> #no_Op

  write: (msg) ->
    console.log(msg)
    @giveInstructions()

  read: (command) ->
    @write("$$ #{command}")
    @onRead?(command)

  giveInstructions: ->
    return if @instructionsGiven
    console.log("Issue commands like this: $$('look')")
    @instructionsGiven = true
