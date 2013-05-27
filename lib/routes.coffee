Q = require 'q'
request = require "request"
Frei = global.Frei

require './mime'
MimeTypes = global.MimeTypes

im = require 'imagemagick'

basic_auth = (user, pass) ->
  credentials = new Buffer "#{user}:#{pass}"
  "Basic #{credentials.toString 'base64'}"

request.get
  url: "#{Frei.config.db.base_url}/validation/teacher"
  headers:
    "content-type": "application/json"
    "accept": "application/json"
    Authorization: basic_auth "security_guard", "ge97hSbSjbi7oT"
  , (err, res) ->
    body = JSON.parse res.body
    return if body.error is "unauthorized"
    Frei.config.db_credentials = basic_auth "teacher", body.key

proxyMeee = (url, req, res) ->
  opts = { method: req.method, url : url }
  opts.headers = {} if typeof opts.headers is 'undefined'
  opts.headers.Authorization = Frei.config.db_credentials if Frei.config.db_credentials?
  request(opts).pipe res

module.exports = class Routes
  @setupPseudoProxy = (app, namespace, AppNamespace, isRoot) ->
    Frei = AppNamespace if typeof Frei is 'undefined'

    @initial_opts = (req, res) ->
      _url = if isRoot then Frei.config.db.base_url else Frei.config.db.url
      _r = if isRoot then "" else "/#{Frei.config.db.name}"
      url = "#{_url}#{req.originalUrl.replace "/#{namespace}#{_r}", ""}"
      opts = { method: req.method, url : url }
      opts.headers = {} if typeof opts.headers is 'undefined'
      opts.headers.Authorization = Frei.config.db_credentials if Frei.config.db_credentials?
      opts.json = req.body if Object.keys(req.body).length
      # TODO - insert user data here from session if missing on update or create
      opts

    app.get /^\/img\/(att\/)?([^/]+)\/([^.]+)/, (req, res) ->
      [ root, id, path ] = req.params[0..2]
      proxyMeee "#{Frei.config.db.url}/#{id}/#{path}", req, res

    app.get /^\/(views\/)?att\/([^/]+)\/([^.]+)/, (req, res) ->
      [ root, id, att_path ] = req.params[0..2]
      proxyMeee "#{Frei.config.db.url}/#{id}/#{att_path}", req, res

    # Proxy requests to CouchDB as it's on a different port
    app.all "/#{namespace}", (req, res) =>
      @proxyToCouch req, res, @initial_opts(req, res)

    app.all "/#{namespace}/*", (req, res) =>
      opts = @initial_opts(req, res)

      # TODO: Have .then() resolved regardless of any promises
      imagePromises = @create_images opts.json
      if imagePromises.length
        # promise is really an array of all all promised results
        Q.all(imagePromises).then((promise) =>
          @proxyToCouch req, res, Object.merge(opts, promise[0])
        ).done()
      else
        @proxyToCouch req, res, opts

  # TODO: Incorporate with proxyMeee
  @proxyToCouch = (req, res, opts) ->
    # TODO - replace this with a `@::before 'delete'` on the client side in
    # the couch adapter, that's where it belongs.
    opts.qs = opts.json if req.method.toLowerCase() is 'delete'
    opts.headers = {} if typeof opts.headers is 'undefined'
    res.contentType opts.headers["content-type"] = opts.headers["accept"] = "application/json"
    request(opts).pipe res

  @create_images = (o, _cb) ->
    promises = []

    if o?._attachment_styles
      styles = o._attachment_styles
      delete o._attachment_styles

    if styles? and o?._attachments?
      originals = o._attachments

      for attr, style_hash of styles
        orig = originals["attr/#{attr}/original"]
        continue unless orig.data
        for style, size of style_hash
          [ w, h ] = size.split 'x'
          do (w,h,orig,style,size,attr) =>
            format = MimeTypes.ext(orig.content_type)
            oo = originals["attr/#{attr}/#{style}"] = content_type: orig.content_type
            imgDefer = @createImageDeferred({
                srcData: (new Buffer orig.data, 'base64').toString('binary'),
                srcFormat: format,
                format: format,
                width: w,
                height: h,
                dstPath: '-'
              }, (img) ->
                oo = originals["attr/#{attr}/#{style}"]
                oo.data = (new Buffer img, 'binary').toString('base64')
                oo
            )
            promises.push imgDefer.promise
    promises

  @createImageDeferred = (imageData, cb) ->
    # NOTE: Can't .defer() because ICS blindly attacks all `defer` strings
    # TODO: Return to sane Q.defer() after ICS is removed
    deferred = Q['defer']()
    im.resize imageData, (err, stdout, stderr) ->
      throw new Frei.DevelopmentError err if err

      result = cb.call(this, stdout)
      deferred.resolve result

    deferred
