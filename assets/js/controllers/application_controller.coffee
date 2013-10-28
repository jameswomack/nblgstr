class BB.Controller extends Batman.Controller

  @accessor 'routingKey', -> Batman.functionName( @constructor).replace /Controller$/, ''

  @accessor "list",
    get: ->
      if @get 'searching'
        @get 'searchResults'
      else
        @get(@get 'defaultModelNamePlural')

  jQuery.expr[":"].contains = (a, i, m) ->
    jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0

  adjustListForSearchNode : (node) ->
    cb = (e,env) =>
      s = []
      if env.rows
        for r in env.rows
          env.subject = BB[ Batman.helpers.classify(r.doc.t) ]
          h = BB.CouchStorage::getRecordFromData r.doc, env.subject
          h.set '_key', r.key
          s.push h
      if s.length
        @set 'searching', yes
        @set "searchResults", s.sort (a,b) -> if a.get("name") >= b.get("name") then 1 else -1 if s
      else
        @resetSearch node, true
    BB.CouchStorage.couchView "#{@get 'defaultModelNameSingular'}_search", {startkey:'"'+$(node).val()+'"', endkey:'"'+$(node).val()+'zzzzz"'}, cb

  resetSearch : (node, keepText) ->
    @set 'searching', no

  filter : (node) ->
    if $(node).val().length == 0 then @resetSearch(node) else @adjustListForSearchNode(node)

  constructor : ->
    k = Batman.helpers.singularize(@constructor.toString().split('function ')[1].split('() {')[0].split('Controller')[0])
    @DefaultModel = BB[k]
    @set 'defaultModelName', k
    @set 'defaultModelNameSingular', k.toLowerCase()
    @set 'defaultModelNamePlural', Batman.helpers.pluralize( k ).toLowerCase()
    @set 'BB', BB
    super arguments...

  goToNew : ->
    @redirect "/#{@get 'defaultModelNamePlural'}/new"

  new : ->
    @set @get('defaultModelNameSingular'), new @DefaultModel
    options = {}
    options["#{@get('defaultModelNameSingular')}"] = @get(@get('defaultModelNameSingular'))
    @set 'cameraView', new BB.CameraView(options)


  index : ->
    @set(@get('defaultModelNamePlural'), new Batman.Set)
    @DefaultModel.load (e, list) =>
      throw e if e?
      @set(@get('defaultModelNamePlural'), new Batman.Set(list...)) if list?


  formSetup = (context) ->
    form = $('form#batmanModel')
    formForAttrPrefix = 'data-formfor-'
    form.removeAttr("#{formForAttrPrefix}instance")
    console.log context
    defaultModelNameSingular = context.get('defaultModelNameSingular')
    console.log defaultModelNameSingular, context
    form.attr("#{formForAttrPrefix}#{defaultModelNameSingular }",defaultModelNameSingular)

  edit : (params) ->
    @set @get('defaultModelNameSingular'), new @DefaultModel
    @DefaultModel.find params.id, (e, instance) =>
      console.error e if e
      @set @get('defaultModelNameSingular'), instance if instance
      options = {}
      options["#{@get('defaultModelNameSingular')}"] = @get(@get('defaultModelNameSingular'))
      @set 'cameraView', new BB.CameraView(options)
    BB.on 'ready', => formSetup(@)


  editCurrentModel : ->
    console.log "foo"
    defaultModelNameSingular = @get('defaultModelNameSingular')
    defaultModelNamePlural = @get('defaultModelNamePlural')
    model = @get(defaultModelNameSingular)
    throw new Error("Model invalid") if !model?
    modelID = model.get('id')
    throw new Error("Model missing ID") if !modelID? 
    viewSingleModelPath = "/#{defaultModelNamePlural}/#{modelID}/edit" 
    @redirect viewSingleModelPath

  createOrUpdate : ->
    defaultModelNameSingular = @get('defaultModelNameSingular')
    model = @get(defaultModelNameSingular)
    throw new Error("Model invalid") if !model?
    model.save (err) =>
      if err
        console.error err
      else
        defaultModelNamePlural = @get('defaultModelNamePlural')
        modelID = model.get('id')
        throw new Error("Model missing ID") if !modelID?
        viewSingleModelPath = "/#{defaultModelNamePlural}/#{modelID}"
        @redirect viewSingleModelPath

  update : ->
    @createOrUpdate arguments...

  create : ->
    @createOrUpdate arguments...

  show : (params) ->
    @set @get('defaultModelNameSingular'), new Batman.Object
    @DefaultModel.find params.id, (e, modelInstance) =>
      console.error e if e
      @set @get('defaultModelNameSingular'), modelInstance if modelInstance
