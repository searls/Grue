#I realized, partway through getting the inventory and item listings up, that
#I'm starting to embed a lot of HTML. Now that I use a lot of templates in my
#day job, it's obvious that inline HTML is a serious maintenance code smell.
#Enter the WebFormatter, which is used by various objects to prepare their output
#in predefined ways. This version still just basically runs off inline HTML,
#but it will be extended to use templates instead.
#
#All WebFormatter method calls recieve an object with two properties: label and
#data (this should be familiar to AS3 coders). You can replace the WebFormatter
#with your own object with no problems, as long as your functions can handle
#these two properties.
#
#Although you can call the WebFormatter methods directly, it probably makes more
#sense to go through WebFormatter.as(), which takes a string key as the first
#argument. as() can provide fallbacks in case of missing methods, whereas
#calling a missing method is a type error in JavaScript. If you define your own
#format object, just copy Format.as over to your version--it'll still work.

Grue.WebFormatter = WebFormatter =
  as: (type, message) ->
    type is "text"  if typeof this[type] is "undefined"
    this[type] message

  text: ->
    lines = Array::slice.call(arguments)
    lines.join "<br>"

  list: (message) ->
    output = message.label
    output += "<ul>"
    data = message.data
    data = [data]  if typeof data is "string" or typeof data is "number"
    i = 0

    while i < data.length
      output += "<li>" + data[i] + "</li>"
      i++
    output += "</ul>"
    output
