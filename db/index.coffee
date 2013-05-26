require '../cuppa'

cradle = require "cradle"

require "#{global.Frei.root}/config"
config = global.Frei.config.db

connection_params = [ config.hostname, config.port, cache: false ]
if config.username and config.password
  connection_params.push { auth: { username: config.username, password: config.password } }

global.Frei.couch = new(cradle.Connection)(connection_params...)

global.Frei.db = db = global.Frei.couch.database(config.name)

db.migrate = (cb) ->
  design = require "./design"
  db.save design._id, design, cb
