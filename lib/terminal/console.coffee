module.exports = class Console
  util = require "util"
  console.debug ?= (args...) ->
    args.forEach (item) ->
      util.debug util.inspect item
