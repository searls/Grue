#The base type for all other objects in the World is the Thing. You extend off
#from Thing by calling Grue.Thing.mutate() and passing in a type ID string and a
#constructor function unique to your type (both of these are optional). Then
#you can add properties to your new prototype at your discretion. Yes,
#everything ends up shallowly inheriting from Thing, but it's probably not a
#good idea to be building deep inheritance chains in your interactive fiction
#anyway. There's always mixins, if you need them.
#
#Things come with some basic shared utility methods:
#
#  - get() - returns a property or function value by key. Similar to _.result()
#
#  - proxy() - lets you intercept calls to get() and interfere with them. Useful
#    for creating "private" properties, as well as for temporarily overriding
#    certain rules.
#
#  - cue() - sets up an action event response. See also:
#
#  - ask() - This is similar to get(), but ask() is meant to be used for user-
#    facing events, while get() is meant to construct your own internal APIs.
#    ask() should return a string, while get() can return anything.
#
#  - nudge() - feed this an object string from the parser, and it will respond
#    with itself if the object "answers" to that name. For simplicity's sake, you
#    can just set this.pattern and use the default nudge function. You'll often
#    invoke nudge() on a Bag of objects to figure out if they respond to a given
#    parser input.
#
#  - say() - output to the browser or UI console via the World. Basically used
#    as a local output method.
#
#
Grue.Thing = Thing = (world) ->
  @classes = []
  @proxies = {}
  @cues = look: ->
    @say @description
    return

  @pattern = /abcdefgh/i
  if world
    @world = world
    world.things.push this
  return

Thing:: =
  name: ""
  description: ""

  #
  #
  #  background and portable are the first of a series of default properties we
  #  should decide to have (or not to have). I would love to have these loaded
  #  from somewhere else, but I haven't figured that out yet. Worst case
  #  scenario, you load these onto Thing.prototype before instantiating your
  #  world.
  #
  #
  background: false
  portable: false
  get: (key) ->
    return null  unless this[key]
    return @proxies[key].call(this)  if @proxies[key]
    if typeof this[key] is "function"
      this[key]()
    else
      this[key]

  proxy: (key, f) ->
    @proxies[key] = f
    return

  ask: (key, event) ->
    return ""  unless @cues[key]
    if typeof @cues[key] is "function"
      response = @cues[key].call(this, event)
      response
    else
      response = @cues[key]
      @say response
      response

  cue: (key, value) ->
    @cues[key] = value
    return

  say: (response) ->
    if @world
      @world.print response
    else
      console.log response
    return

  nudge: (input) ->
    result = @pattern.test(input)
    this  if result


#
#
#Why mutate() all the Things? A couple of reasons:
#
#  First, we want to inherit from Thing using good JavaScript prototypes, but
#  calling Thing.call(this) for our super-constructor is annoying--as is the
#  need to constantly check whether the constructor is being called via "new"
#  or via the factory. Using mutate(), we make sure that a fresh type is
#  constructed, but the constructor boilerplate is still abstracted away. This
#  boilerplate includes one bit of world-building magic: Thing constructors
#  called from a World object will automatically add themselves to it for
#  access via the world's convenience collection methods.
#
#  Second, JavaScript constructor patterns are terrible. This library aims to
#  be, as much as possible, a tool for people who are not JavaScript gurus. As
#  a result, we want to isolate users from the brittleness of constructor
#  function/prototype/prototype.constructor as much as possible. Using mutate()
#  (and, more often, using the factory functions via the World object) keeps
#  the inheritable madness to a minimum.
Thing.mutate = (tag, f) ->
  if typeof tag is "function"
    f = tag
    tag = "Thing"
  f = f or ->

  Type = (world) ->
    unless this instanceof Type
      return new Type(this)  if this instanceof Grue.World
      return new Type()
    Thing.call this, world
    f.call this
    return

  Type:: = new Thing()
  Type::type = tag
  Type
