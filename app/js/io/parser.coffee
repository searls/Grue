#You'll rarely interact with the Parser directly, although it's there if you
#need to. Instead, the World instantiates a parser for itself, and you'll use
#its utility methods to add command mappings indirectly.

Grue.Parser = Parser = (world, console) ->
  @world = world
  @attach console  if console
  @rules = []
  return

Parser:: =
  errorMessage: "I don't understand that."
  attach: (console) ->
    @console = console
    console.onRead = @input.bind(this)
    return

  input: (line) ->
    sentence = @evaluate(line)
    @console.write @errorMessage  if sentence is false
    return

  #  Rule definitions consist of two parts: a regular expression pattern used
  #  to parse out the command, and a responder function that does something
  #  based on the parts that are passed back. So you might have a look command:
  #
  #  /(look|examine|describe)\s(at\s)*([\w\s])/i
  #
  #  and then a responder function that turns it into an action:
  #
  #  function(parts) {
  #    var verb = 'look';
  #    var object = parts[3];
  #    //gather items that respond to that name
  #    var prospects = world.localThings().invoke('nudge', object);
  #    if (prospects.length > 1) {
  #      return "I'm not sure which '" + object + "' you mean.";
  #    } else if (prospects.length) {
  #      return prospects.getAt(0).ask(verb);
  #    }
  #    return false;
  #  }
  #
  #  If you pass a String instead of a regular expression to addRule, it will
  #  attempt to compile it using a simple parameter conversion. See compileRule()
  #  below for more details.

  addRule: (pattern, responder) ->
    if typeof pattern is "string"
      @rules.push @compileRule(pattern, responder)
    else
      @rules.push
        pattern: pattern
        responder: responder

    return

  #  Many commands are simple enough that you shouldn't need to write regular
  #  expressions for them. The parser will try to compile a space-delimited
  #  string into a regular expression for you, using a simple, route-like syntax.
  #  For example, we might write:
  #
  #  attack :monster with? :weapon?
  #
  #  Words preceded with a colon are named parameters, and those followed with a
  #  question mark are optional. Even though JavaScript's regular expression
  #  engine lacks named parameters, we can fake it by wrapping the responder in a
  #  function that adds our parameters to the match array.
  compileRule: (pattern, responder) ->
    words = pattern.split(" ")
    positions = {}
    i = 0

    while i < words.length
      original = words[i]
      words[i] = original.replace(/[?:]/g, "")
      if original.substr(0, 1) is ":"
        positions[words[i]] = i + 1
        words[i] = "\\w+"
      words[i] = "(" + words[i] + ")"
      words[i] += "*"  if original.substr(-1) is "?"
      i++
    compiled = new RegExp(words.join("\\s*"))
    filter = (matches) ->
      for key of positions
        matches[key] = matches[positions[key]]
      responder.call this, matches
      return

    pattern: compiled
    responder: filter


  #  Rules are evaluated in first-in, first-out order. If no matching rule is
  #  found, it returns false. Rule response functions are called in the
  #  context of the world (this == the world).
  evaluate: (input) ->
    i = 0

    while i < @rules.length
      rule = @rules[i]
      matches = rule.pattern.exec(input)
      return rule.responder.call(@world, matches)  if matches
      i++
    false
