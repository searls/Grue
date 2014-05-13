Grue.DevelopmentConsole = class
  constructor: ->
    window.say = _(@read).bind(this)

  attach: -> #no_Op

  write: (msg) ->
    console.log(msg)

  read: (command) ->
    @write("$ #{command}")
    @onRead?(command)
