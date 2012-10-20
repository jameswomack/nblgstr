module.exports = class Mack extends require('events').EventEmitter
  @address = undefined
  os = require 'os'
  exec = require('child_process').exec

  on: (event, listener) ->
    super
    @mackDown() if event is 'addressFound'

  mackDown: ->
    cmd = "/sbin/ifconfig | grep -o -E -m 1 '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | sed 's/[:]//g'"
    exec cmd, =>
      @address = arguments[1].trimRight()
      @emit 'addressFound', @address
