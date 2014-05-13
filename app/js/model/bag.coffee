# Bag is a kind of limited-use underscore.js - an explicitly-unsorted collection
# type, aimed directly at objects, that allows for filtering and mapped get/set
# operations. Many operations on Bags are chainable. You can also query Bags by
# property values, similar to a bracket-less CSS attribute selector. A Bag is
# an apt metaphor for this: you basically put objects into it and then grope
# around blindly for what you need later on.

Grue.Bag = Bag = (array) ->
  return new Bag(array)  unless this instanceof Bag
  @items = []
  if array
    array = array.toArray()  unless typeof array.toArray is "undefined"
    @items = @items.concat(array)
  @length = @items.length
  return

Bag::push = ->
  @items.push.apply @items, Array::slice.call(arguments)
  @length = @items.length
  this

Bag::add = Bag::push
Bag::remove = (item) ->
  remaining = []
  i = 0

  while i < @items.length
    remaining.push @items[i]  unless @items[i] is item
    i++
  @items = remaining
  @length = @items.length
  this

Bag::first = ->
  @items[0]

Bag::at = (n) ->
  @items[n]

Bag::contains = (o) ->
  @items.indexOf(o) isnt -1

Bag::filter = (f) ->
  filtered = []
  i = 0

  while i < @items.length
    filtered.push @items[i]  if f(@items[i])
    i++
  new Bag(filtered)

Bag::map = (f) ->
  mapped = @items.map(f)
  new Bag(mapped)

Bag::reduce = (f, initial) ->
  @items.reduce f, initial

Bag::mapGet = (p) ->
  @items.map (item) ->
    item[p]


Bag::mapSet = (p, value) ->
  i = 0

  while i < @items.length
    @items[i][p] = value
    i++
  this

Bag::invoke = (name) ->
  args = Array::slice.call(arguments, 1)
  map = []
  i = 0

  while i < @items.length
    item = @items[i]
    continue  unless typeof item[name] is "function"
    result = item[name].apply(item, args)
    map.push result  unless typeof result is "undefined"
    i++
  new Bag(map)

Bag::each = (f) ->
  i = 0

  while i < @items.length
    f @items[i]
    i++
  this

Bag::some = (f) ->
  i = 0

  while i < @items.length
    result = f(@items[i])
    break  if result is false
    i++
  this

Bag::toArray = ->
  @items

Bag::combine = ->
  args = Array::slice.call(arguments)
  i = 0

  while i < args.length
    adding = args[i]
    if adding instanceof Bag
      @items = @items.concat(adding.items)
    else
      @items = @items.concat(adding)
    @length = @items.length
    return this
    i++
  return



# We only query on attributes--it saves selector complexity. The supported
# selector operators are:
#   =   equals
#   >   greater than
#   >=  greater than or equal to
#   <   less than
#   <=  less than or equal to
#   !=  not equal to
#   ?  truthiness
#   ~=  array contains
#   ^=  string begins
#   $=  string ends
#   *=  string contains
#
# Multiple selectors can be passed in using a comma. These act as AND operators,
# brackets.

Bag::query = (selectors) ->
  selectors = selectors.split(",")
  matcher = "^\\s*(\\w+)\\s*([<>!~$*^?=]{0,2})\\s*\\\"{0,1}([^\\\"]*)\\\"{0,1}\\s*$"
  tests =
    "=": (a, b) ->
      a is b

    ">": (a, b) ->
      a > b

    ">=": (a, b) ->
      a >= b

    "<": (a, b) ->
      a <= b

    "!=": (a, b) ->
      a isnt b

    "?": (a) ->
      a

    "~=": (a, b) ->
      return false  if typeof a.length is "undefined"
      unless typeof Array::indexOf is "undefined"
        a.indexOf(b) isnt -1
      else
        i = 0

        while i < a.length
          return true  if a[i] is b
          i++
        false

    "^=": (a, b) ->
      return false  unless typeof a is "string"
      a.search(b) is 0

    "$=": (a, b) ->
      return false  unless typeof a is "string"
      a.search(b) is a.length - b.length

    "*=": (a, b) ->
      return false  unless typeof a is "string"
      a.search(b) isnt -1

    fail: ->
      false

  i = 0

  while i < selectors.length
    parts = new RegExp(matcher).exec(selectors[i])
    throw ("Bad selector: " + selectors[i])  unless parts
    selectors[i] =
      key: parts[1]
      operator: parts[2]

    value = parts[3].replace(/^\s*|\s*$/g, "")
    if value is "true" or value is "false"
      value = value is "true"
    else value = parseFloat(value)  if value isnt "" and not isNaN(value)
    selectors[i].value = value
    i++
  passed = []
  i = 0

  while i < @items.length
    item = @items[i]
    hit = true
    j = 0

    while j < selectors.length
      s = selectors[j]
      if typeof item[s.key] is "undefined"
        hit = false
        break
      else if s.operator
        f = tests[s.operator] or tests.fail
        unless f(item[s.key], s.value)
          hit = false
          break
      j++
    passed.push item  if hit
    i++
  new Bag(passed)
