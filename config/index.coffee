NG = {} if !NG?
global = window if !global? && window?
global.NG = NG
NG.config = {} if !NG.config?
NG.env = "development" if !NG.env?

NG._cs = _cs = ( c, s ) -> if window? then c else s

NG.config.http ?= {}
NG.config.http.port = process?.env.PORT || location?.port || 3000
NG.config.http.port = parseInt NG.config.http.port

data =
  base:
    proto: 'http'
    hostname: 'localhost'
    port: _cs NG.config.http.port, 5984
    view_id: 'app'
    url_auth_string: ''
  test:
    name: _cs "api/test", "test"
  development:
    name: _cs "api/ng", "ng"

if process?
  env = process.env
  if env.COUCH_USERNAME and env.COUCH_PASSWORD
    u = data.base.username = env.COUCH_USERNAME
    p = data.base.password = env.COUCH_PASSWORD
    data.base.url_auth_string = "#{u}:#{p}@"

NG.config.db = config = data[NG.env]
config[k] = v for k, v of data.base
NG.config.db.base_url = base_url = "#{config.proto}://#{config.url_auth_string}#{config.hostname}:#{config.port}"
NG.config.db.url = "#{base_url}/#{config.name}"
