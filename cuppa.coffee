global.Frei = {} if typeof global.Frei is 'undefined'
Frei = global.Frei

path    = require 'path'
express = require 'express'
assets  = require 'connect-assets'
sugar   = require 'sugar'
request = require 'request'
fs      = require 'fs'
passport = require('passport')
LocalStrategy = require('passport-local').Strategy
RedisStore = require('connect-redis')(express)
expressUglify = require 'express-uglify'

CookieJar = require './app/models/cookie_jar'
UserController = require './app/controllers/user_controller'

Frei.root = path.normalize "#{__dirname}"
Frei.app  = app = express.createServer()
Frei.env  = process.env["NODE_ENV"] || "development"
Frei.noAuthPath = "/_login/index.html"

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

  app.use(express.logger())

  app.use expressUglify.middleware
    src: __public,
    logLevel: 'info',

  app.use express.static __public
  app.use express.bodyParser keepExtensions: true, uploadDir: __uploads
  app.use(express.cookieParser())
  app.use(express.methodOverride())
  app.use(express.session({
      secret: 'X3n0ph0bic1984',
      store: new RedisStore,
      cookie: { secure: false, maxAge:CookieJar.cookieMaxAge }
  }))
  app.use(passport.initialize())
  app.use(passport.session())

  app.set 'view options', layout: false
  app.set 'views', "#{__assets}/views"
  app.set 'view engine', 'jade'

Routes = require "#{__lib}/routes"
Routes.setupPseudoProxy app, 'api', Frei

Mack = require("#{__lib}/mack")
mack = new Mack
@MACaddress = ''
mack.on 'addressFound', (a) =>
  @MACaddress = a


passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  process.nextTick ->
    Frei.db.get id, (err, user) ->
      done null, user

passport.use new LocalStrategy((username, password, done) ->
  process.nextTick ->
    Frei.db.view 'app/user_pass_search', { key: [username, password] }, (err, docs) ->
      done null, docs[0]
)

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect Frei.noAuthPath

app.post "/login", passport.authenticate("local",
  successRedirect: "/"
  failureRedirect: Frei.noAuthPath
)

app.get "/logout", (req, res) ->
  CookieJar.resCookie res, 'user_id', null
  req.logout()
  res.redirect req.header('Referer') || Frei.noAuthPath

app.get '/views/:controller/edit.html', ensureAuthenticated, (req, res) ->
  res.render "#{req.params.controller}/edit"

app.get '/views/:controller/new.html', ensureAuthenticated, (req, res) ->
  res.render "#{req.params.controller}/new"

app.get '/views/:controller/:action.html', (req, res) ->
  res.render "#{req.params.controller}/#{req.params.action}"

app.get '/uuidURL', ensureAuthenticated, (req, res) =>
  opts = method: req.method, url: "#{Frei.config.db.base_url}/_uuids"
  opts.headers = {} if typeof opts.headers is 'undefined'
  db_creds = Frei.config.db_credentials
  opts.headers.Authorization = db_creds if db_creds?
  res.contentType opts.headers["content-type"] = opts.headers["accept"] = "application/json"
  request.get opts, (e, r, body) =>
    res.json uuid: "#{JSON.parse(body).uuids[0]}_#{@MACaddress}", 200

app.get /^\/img\/([^/]+)\/([^.]+)/, (req, res) ->
  [ id, path ] = req.params[0..1]
  request("#{Frei.config.db.url}/#{id}/#{path}").pipe res

app.post '/upload', ensureAuthenticated, (req, res) ->
  picture = req.files.picture
  if picture isnt undefined
    require("#{__lib}/fotoshop").fit picture.path, 1024, 768, (error, imageData, content_type) =>
      data = (new Buffer imageData, 'binary').toString('base64') unless error
      res.json content_type: content_type, data: data , error: error
  else
    error = new Error "req.files.picture is undefined"
    res.json error: error

app.get '/*', (req, res) ->
  Frei.back_url = req.cookies.back_url
  CookieJar.resCookie res, 'user_id', UserController.idFromReq(req)
  res.render "index",
      layout: false
      node_env: Frei.env
      stylesheet: asset_helper.css("screen")
      scripts: asset_helper.js("app")
      title: "Hot Babes and Cool Cervezas | Babes & Brewskies"
      status: 200

if module.parent
  module.exports = Frei
else
  app.listen Frei.config.http.port
  console.log "Frei is listening on #{Frei.config.http.port}"
