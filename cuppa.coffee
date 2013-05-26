global.Frei = {} if typeof global.Frei is 'undefined'
Frei = global.Frei

path    = require 'path'
express = require 'express'
assets  = require 'connect-assets'
sugar   = require 'sugar'
request = require 'request'
fs      = require 'fs'

Frei.root = path.normalize "#{__dirname}"
Frei.app  = app = express.createServer()
Frei.env  = process.env["NODE_ENV"] || "development"

__lib     = "#{Frei.root}/lib"
__public  = "#{Frei.root}/public"
__assets  = "#{Frei.root}/assets"
__uploads = "#{__public}/uploads"

require "./config"
require "./db"
require "#{__lib}/terminal/console"

asset_helper = {}
app.configure ->
  compilers =
    coffee:
      compileSync: (sourcePath, source) ->
        (require "coffee-script").compile source, filename: sourcePath, runtime: "window"
  app.set "assets", assets
  app.use assets( src: __assets, pathsOnly: true, jsCompilers: compilers, helperContext: asset_helper)

  app.use "/#{a}", express.static "#{__assets}/#{a}" for a in fs.readdirSync __assets

  app.use express.static __public
  app.use express.bodyParser keepExtensions: true, uploadDir: __uploads

  app.set 'views', "#{__assets}/views"
  app.set 'view engine', 'jade'

Routes = require "#{__lib}/routes"
Routes.setupPseudoProxy app, 'api', Frei

Mack = require("#{__lib}/mack")
mack = new Mack
@MACaddress = ''
mack.on 'addressFound', (a) =>
  @MACaddress = a

app.get '/views/:controller/:action.html', (req, res) ->
  res.render "#{req.params.controller}/#{req.params.action}", layout: false

app.get '/uuidURL', (req, res) =>
  opts = method: req.method, url: "#{Frei.config.db.base_url}/_uuids"
  opts.headers ?= {}
  db_creds = Frei.config.db_credentials
  opts.headers.Authorization = db_creds if db_creds?
  res.contentType opts.headers["content-type"] = opts.headers["accept"] = "application/json"
  request.get opts, (e, r, body) =>
    res.json uuid: "#{JSON.parse(body).uuids[0]}_#{@MACaddress}", 200

app.get /^\/img\/([^/]+)\/([^.]+)/, (req, res) ->
  [ id, path ] = req.params[0..1]
  request("#{Frei.config.db.url}/#{id}/#{path}").pipe res

app.post '/upload', (req, res) ->
  if req.files.picture isnt undefined
    require("#{__lib}/fotoshop").fit req.files.picture.path, 1024, 768, (anError, theImage, theMIME) =>
      _base64data = (new Buffer theImage, 'binary').toString('base64') unless anError
      res.json content_type: theMIME, data: _base64data, error: anError
  else
    err = new Error "req.files.picture is undefined"
    res.json error: err

app.get '/*', (req, res) ->
  res.render "index",
    layout: false
    node_env: Frei.env
    stylesheet: asset_helper.css("screen")
    scripts: asset_helper.js("app")
    title: "Mobile & Web Software Development | Noble Gesture"
    status: 200

if module.parent
  module.exports = Frei
else
  app.listen Frei.config.http.port
  console.log "Frei is listening on #{Frei.config.http.port}"
