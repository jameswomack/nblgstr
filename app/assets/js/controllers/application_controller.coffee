class NG.Controller extends Batman.Controller

  @accessor 'routingKey', -> Batman.functionName( @constructor).replace /Controller$/, ''

  @accessor "list",
    get: ->
      if @get 'searching'
        @get 'searchResults'
      else
        @get "#{@get 'defaultModelNamePlural'}"

  jQuery.expr[":"].contains = (a, i, m) ->
    jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0

  adjustListForSearchNode : (node) ->
    cb = (e,env) =>
      s = []
      if env.rows
        for r in env.rows
          env.subject = NG[ Batman.helpers.classify(r.doc.t) ]
          h = NG.CouchStorage::getRecordFromData r.doc, env.subject
          h.set '_key', r.key
          s.push h
      if s.length
        @set 'searching', yes
        @set "searchResults", s.sort (a,b) -> if a.get("name") >= b.get("name") then 1 else -1 if s
      else
        @resetSearch node, true
    NG.CouchStorage.couchView "#{@get 'defaultModelNameSingular'}_search", {startkey:'"'+$(node).val()+'"', endkey:'"'+$(node).val()+'zzzzz"'}, cb

  resetSearch : (node, keepText) ->
    @set 'searching', no

  filter : (node) ->
    if $(node).val().length == 0 then @resetSearch(node) else @adjustListForSearchNode(node)

  constructor : ->
    k = Batman.helpers.singularize(@constructor.toString().split('function ')[1].split('() {')[0].split('Controller')[0])
    @DefaultModel = NG[k]
    @set 'defaultModelName', k
    @set 'defaultModelNameSingular', k.toLowerCase()
    @set 'defaultModelNamePlural', Batman.helpers.pluralize( k ).toLowerCase()
    @set 'NG', NG
    super arguments...

  goToNew : ->
    @redirect "/#{@get 'defaultModelNamePlural'}/new"

  new : ->
    @set "instance", new @DefaultModel
    @set 'cameraView', new NG.CameraView instance: @get('instance')
    NG.on 'ready', =>
        $('form').removeAttr('data-formfor-instance').attr('data-formfor-'+@get('defaultModelNameSingular'),'instance')

  index : ->
    @set "#{@get 'defaultModelNamePlural'}", new Batman.Set
    @DefaultModel.load (e, list) =>
      console.error e if e
      @set "#{@get 'defaultModelNamePlural'}", list if list

  edit : (params) ->
    @set "instance", new @DefaultModel
    @DefaultModel.find params.id, (e, instance) =>
      console.error e if e
      @set "instance", instance if instance
      @set 'cameraView', new NG.CameraView instance: instance
    NG.on 'ready', =>
      $('form').removeAttr('data-formfor-instance').attr('data-formfor-'+@get('defaultModelNameSingular'),'instance')

  createOrUpdate : ->
    @get('instance').save (err) =>
      if err
        console.error err
      else
        @redirect "/#{@get 'defaultModelNamePlural'}/#{@get('instance').get('id')}"

  update : ->
    @createOrUpdate arguments...

  create : ->
    @createOrUpdate arguments...

  show : (params) ->
    @set 'instance', new Batman.Object
    @DefaultModel.find params.id, (e, modelInstance) =>
      console.error e if e
      @set 'instance', modelInstance if modelInstance
