exec = require 'exec'
util = require 'util'
exec "ls -al", (err, stdout, stderr) ->
  util.puts "hello"
  util.puts stdout

