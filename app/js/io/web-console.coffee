#The WebConsole (not to be confused with the browser console) exists to direct
#input into the parser and handle output from it. You don't need to directly
#instantiate a console unless you really want to--the World will create one as
#its "io" property, and then you can wire it up to an input field and an
#element for output.

Grue.WebConsole = WebConsole = (input, output) ->
  @attach input, output  if input and output
  @onKey = @onKey.bind(this)
  @memory = []
  @memoryPointer = 0
  return

WebConsole:: =
  tagName: "div"
  className: "console-line"
  echoClass: "console-echo"
  echoQuote: "> "
  memory: null
  memoryPointer: 0
  attach: (input, output) ->
    @input.removeEventListener "keyup", @onKey  if @input
    @input = input
    @input.addEventListener "keyup", @onKey
    @output = output
    return

  onKey: (e) ->
    switch e.keyCode
      when 13
        input = @input.value
        @memory.unshift input
        @memoryPointer = 0
        @read input
        @input.value = ""
      when 38 #up
        @input.value = @memory[@memoryPointer] or @input.value
        @memoryPointer++

  read: (line) ->
    @write line, true
    @onRead line  if @onRead
    return

  write: (text, echo) ->
    tag = document.createElement(@tagName)
    tag.className = (if echo then [
      this.className
      this.echoClass
    ].join(" ") else @className)
    tag.innerHTML = (if echo then @echoQuote + text else text)
    @output.appendChild tag
    @onUpdate()  if @onUpdate
    return

  onUpdate: null
