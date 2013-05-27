class Frei.Controller extends Batman.Controller


  @afterFilter ->
    $.cookie 'back_url', location.pathname


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
          env.subject = Frei[ Batman.helpers.classify(r.doc.t) ]
          h = Frei.CouchStorage::getRecordFromData r.doc, env.subject
          h.set '_key', r.key
          s.push h
      if s.length
        @set 'searching', yes
        @set "searchResults", s.sort (a,b) -> if a.get("name") >= b.get("name") then 1 else -1 if s
      else
        @resetSearch node, true
    Frei.CouchStorage.couchView "#{@get 'defaultModelNameSingular'}_search", {startkey:'"'+$(node).val()+'"', endkey:'"'+$(node).val()+'zzzzz"'}, cb


  resetSearch : (node, keepText) ->
    @set 'searching', no


  filter : (node) ->
    if $(node).val().length == 0 then @resetSearch(node) else @adjustListForSearchNode(node)


  constructor : ->
    k = Batman.helpers.singularize(@constructor.toString().split('function ')[1].split('() {')[0].split('Controller')[0])
    @DefaultModel = Frei[k]
    @set 'defaultModelName', k
    @set 'defaultModelNameSingular', k.toLowerCase()
    @set 'defaultModelNamePlural', Batman.helpers.pluralize( k ).toLowerCase()
    @set 'Frei', Frei
    super arguments...


  goToNew : ->
    @redirect "/#{@get 'defaultModelNamePlural'}/new"


  new : ->
    @set "instance", new @DefaultModel
    @set 'cameraView', new Frei.CameraView instance: @get('instance')
    Frei.on 'ready', =>
        $('form').removeAttr('data-formfor-instance').attr('data-formfor-'+@get('defaultModelNameSingular'),'instance')


  index : ->
    if @DefaultModel
      @set "#{@get 'defaultModelNamePlural'}", new Batman.Set
      @DefaultModel.load (e, list) =>
        console.error e if e
        @set "#{@get 'defaultModelNamePlural'}", list if list


  index_destroy : (n) ->
    node = $(n)
    id = node.attr('title')
    @DefaultModel.find id, (e, instance) =>
      if e
        console.error e
      else
        return unless @has_edit_permission(instance)
        instance.destroy()
        node.parent().hide('slow')


  has_edit_permission: (instance) ->
    if instance?
      _instance = instance
    else
      _instance = @get('instance')
    Boolean(_instance.get('user.id') is $.cookie('user_id'))


  @accessor 'user_logged_in',
    get: ->
      $.cookie('user_id') != 'undefined'


  edit : (params) ->
    return unless @has_edit_permission()
    @set "instance", new @DefaultModel
    @DefaultModel.find params.id, (e, instance) =>
      console.error e if e
      @set "instance", instance
      @set 'cameraView', new Frei.CameraView instance: instance

    Frei.on 'ready', =>
      $('form').removeAttr('data-formfor-instance').attr('data-formfor-'+@get('defaultModelNameSingular'),'instance')


  edit_to_show : ->
    @redirect "/#{@get 'defaultModelNamePlural'}/#{@get('instance').get('id')}"


  createOrUpdate : ->
    return unless @has_edit_permission()
    @get('instance').save (err) =>
      if err
        console.error err
      else
        @edit_to_show()


  update : ->
    @createOrUpdate arguments...


  create : ->
    @createOrUpdate arguments...


  show : (params) ->
    @set 'instance', new Batman.Object
    @DefaultModel.find params.id, (e, modelInstance) =>
      console.error e if e
      @set 'instance', modelInstance if modelInstance
      @setup_location()


  show_to_edit : ->
    return unless @has_edit_permission()
    @redirect "/#{@get 'defaultModelNamePlural'}/#{@get('instance').get('id')}/edit"


  show_location : (lat, lon, title, src) ->
    coordinate = [lat, lon]
    if !@map
      @map = L.map('map').setView(coordinate, 16)
    L.tileLayer('http://{s}.tile.cloudmade.com/05afaa8abaa74deaabbf7c99e68bc716/997/256/{z}/{x}/{y}.png', {
        maxZoom: 18
    }).addTo(@map)
    marker = L.marker(coordinate).addTo(@map)
    marker.bindPopup("<img src=\"#{src}\" width=\"60\"/><br><strong>#{title}</strong>").openPopup()


  setup_location : ->
    coordReq = Frei.NominatumMessenger.coordinatesFromStreetAndCity
    inst = @get 'instance'
    coordReq inst.get('street'), inst.get('city'), inst.get('state'), (lat, lon) =>
      @set 'instance.latitude', lat
      @set 'instance.longitude', lon
      @show_location lat, lon, @get('instance.title') || @get('instance.name'), @get('instance.picture_thumb')
    , =>
      $('#map').text("Could not map this address")


  placeholderConformantMatcher: 'input[type=text], textarea'


  autofillNode : (n) ->
    placeholder_conformant_n = $(n).find(@placeholderConformantMatcher)[0]
    placeholder_conformant = $(placeholder_conformant_n)
    placeholder = placeholder_conformant.attr('placeholder')
    data_bind_key = placeholder_conformant.attr('data-bind').split('.')[1]
    @set "instance.#{data_bind_key}", placeholder


  autofill : (n, e) ->
    @autofillNode n


  autofillAll : (n, e) ->
    $(n).parent().find('label').each (idx, n) =>
      @autofillNode n
