window.Frei = {} if typeof window.Frei is 'undefined'
Frei = window.Frei
Frei.config = {} if typeof Frei.config is 'undefined'
Frei.env = "development" if typeof Frei.env is 'undefined'

Frei.config.http = {} if typeof Frei.config.http is 'undefined'
Frei.config.http.port = location?.port || 3000
Frei.config.http.port = parseInt Frei.config.http.port

data =
  base:
    proto: 'http'
    hostname: 'localhost'
    port: Frei.config.http.port
    view_id: 'app'
    url_auth_string: ''
  test:
    name: "api/test"
  development:
    name: "api/frei"

Frei.config.db = config = data[Frei.env]
config[k] = v for k, v of data.base
Frei.config.db.base_url = base_url = "#{config.proto}://#{config.url_auth_string}#{config.hostname}:#{config.port}"
Frei.config.db.url = "#{base_url}/#{config.name}"
