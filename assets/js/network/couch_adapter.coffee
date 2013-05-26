class Frei.CouchStorage extends Batman.RestStorage
  serializeAsForm: false

  _defaultCollectionUrl: (_) -> Frei.config.db.name
  urlForCollection: (model, env) ->
    view = env.options.data.view
    view_id = env.options.data.view_id ? Frei.config.db.view_id
    env.options.data.key = JSON.stringify env.options.data.key if env.options.data.key
    if (not view?) and (modelType = Batman.helpers.singularize(@storageKey(model.prototype)))
      view = "type"
      env.options.data.key = JSON.stringify modelType
    [ "#{window.location.protocol}//#{window.location.host}", @_defaultCollectionUrl(), '_design', view_id, '_view', view].join('/')

  @::before 'destroy', @skipIfError (env, next) ->
    subject = env.subject
    data = subject.toJSON()
    data.rev = subject.get "_rev"
    env.options.data = data
    next()

  @::before 'readAll', @skipIfError (env, next) ->
    env.options.data.include_docs = true unless env.options.data.include_docs?
    next()

  @::before 'create', 'update', @skipIfError (env, next) ->
    subject = env.subject
    data = subject.toJSON()
    if namespace = @recordJsonNamespace(subject)
      data.t = namespace

    # Largely duplicated from RestStorage. See https://github.com/Shopify/batman/issues/334.
    if @serializeAsForm
      # Leave the POJO in the data for the request adapter to serialize to a body
      env.options.contentType = @constructor.PostBodyContentType
    else
      data = JSON.stringify(data)
      env.options.contentType = @constructor.JSONContentType

    env.options.data = data

    _data = JSON.parse data

    if env.subject.get('id')?
      _data.updated_time = new Date().toJSON()
      @readyToSave env, _data, next
    else
      $.get '/uuidURL', (o) =>
        _data._id = o.uuid
        _data.created_time = new Date().toJSON()
        @readyToSave env, _data, next

  readyToSave: (env, data, next) ->
    env.options.data = JSON.stringify(data)
    next()

  # TODO - update is only needed here because of https://github.com/Shopify/batman/pull/447
  @::after 'create', 'update', @skipIfError (env, next) ->
    if Batman.typeOf(env.data) is 'Object'
      data = env.data
    else
      data = JSON.parse env.data

    subject = env.subject

    subject._withoutDirtyTracking ->
      subject.set 'id', data.id
      subject.set '_rev', data.rev
    env.result = subject
    next()

  @::after 'readAll', @skipIfError (env, next) ->
    if env.json.rows
      env.result = env.records =
        for r in env.json.rows
          #TODO treat cause, not symptom
          continue unless r.doc?
          h = @getRecordFromData r.doc, env.subject
          h.set '_key', r.key
          h
      next()

  @couchView: (view, data = {}, cb) ->
    console.log arguments
    data.include_docs = 'true' unless data.include_docs?
    new Batman.Request
      url: @::urlForCollection( Object.extended(), options: data: view: view)
      type: "json"
      data: data
      success: (response) =>
        cb null, response
