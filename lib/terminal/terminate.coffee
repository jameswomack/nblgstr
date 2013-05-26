module.exports = class Terminate
  terminal = require 'node-terminal'

  @line: ->
    console.log "\n"

  @bangline: ->
    terminal.colorize "%g########################\n%n"

  @albinize: (s) ->
    terminal.colorize "%W#{s}\n%n"

  @foreplay: ->
    @line()
    @bangline()

  @moreplay: ->
    @bangline()
    @line()

  @putk: (k) ->
    terminal.colorize "%B#{k.toUpperCase()}:\n%n"

  @putv: (v) ->
    terminal.colorize "%p#{v}\n\n%n"

  @putp: (k,v) ->
    @putk k
    @putv v

  @puto: (o) ->
    @putp k,v for k,v of o