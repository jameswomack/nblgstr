module.exports = class Console
  util = require "util"
  if typeof console.debug is 'undefined'
    console.debug = (args...) ->
      args.forEach (item) ->
        util.debug util.inspect item
