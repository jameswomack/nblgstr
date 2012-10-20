require '../cuppa'

cradle = require "cradle"
NG = global.NG

require "#{NG.root}/config"
config = NG.config.db

couch = new(cradle.Connection)(config.hostname, config.port, cache: false)

NG.db = db = couch.database(config.name)

db.migrate = (cb) ->
  design = require "./design"
  db.save design._id, design, cb
