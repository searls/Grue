Grue.DevelopmentFormatter =
  as: (type, message) ->
    this[type](message)

  text: ->
    Array::slice.call(arguments).join("\n")

  list: (message) ->
    data = message.data
    data = [data] if typeof data is "string" or typeof data is "number"
    i = 0
    output = "\n#{message.label}" if data.length > 0
    while i < data.length
      output += "\n  * #{data[i]}"
      i++
    output
