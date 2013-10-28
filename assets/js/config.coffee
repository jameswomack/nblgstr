global = window if !global? && window?
BB = global.BB
BB.config ?= {}
BB.env ?= "development"

BB.config.http ?= {}
BB.config.http.port = 3000

data =
  base:
    proto: 'http'
    hostname: 'localhost'
    port: BB.config.http.port
    view_id: 'app'
    url_auth_string: ''
  test:
    name: "api/test"
  development:
    name: "api/bb"

BB.config.db = config = data[BB.env]
config[k] = v for k, v of data.base
BB.config.db.base_url = base_url = "#{config.proto}://#{config.hostname}:#{config.port}"
BB.config.db.url = "#{base_url}/#{config.name}"
