# Exports a function which returns an object that overrides the default &
#    plugin file patterns (used widely through the app configuration)
#
#  To see the default definitions for Lineman's file paths and globs, see:
#
#    - https://github.com/linemanjs/lineman/blob/master/config/files.coffee
#
module.exports = (lineman) ->
  coffee:
    app: [
      "app/js/grue.coffee"
      "app/js/model/thing.coffee"
      "app/js/model/**/*.coffee"
      "app/js/model/world.coffee"
      "app/js/io/**/*.coffee"
      "app/js/**/*.coffee"
      "app/js/base-rules.coffee"
    ]
