authority = require '../lib/couchdb_utils/authority'

global.Frei = {} if typeof global.Frei is 'undefined'
Frei = global.Frei
Frei.config = {} if typeof Frei.config is 'undefined'
Frei.env = "development" if typeof Frei.env is 'undefined'

Frei.config.http = {} if typeof Frei.config.http is 'undefined'
Frei.config.http.port = process?.env.PORT || location?.port || 3000
Frei.config.http.port = parseInt Frei.config.http.port

data =
  base:
    proto: 'http'
    hostname: 'localhost'
    port: 5984
    view_id: 'app'
    url_auth_string: ''
  test:
    name: "test"
  development:
    name: "frei"

data.base.url_auth_string = authority.assign(data.base)

Frei.config.db = data[Frei.env]
Frei.config.db[k] = v for k, v of data.base
config = Frei.config.db
Frei.config.db.base_url = base_url = "#{config.proto}://#{config.url_auth_string}#{config.hostname}:#{config.port}"
Frei.config.db.url = "#{base_url}/#{config.name}"
