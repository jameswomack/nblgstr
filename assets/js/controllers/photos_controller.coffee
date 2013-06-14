class Frei.PhotosController extends Frei.Controller
  @accessor "storesList",
    get: ->
      if @get 'searchingStores'
        @get 'storeSearchResults'
      else
        @get "stores"


  jQuery.expr[":"].contains = (a, i, m) ->
    jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0


  adjustListForStoreSearchNode : (node) ->
    photo = @
    cb = (e,env) ->
      s = []
      if env.rows
        for r in env.rows
          env.subject = Frei[ Batman.helpers.classify(r.doc.t) ]
          h = Frei.CouchStorage::getRecordFromData r.doc, env.subject
          h.set '_key', r.key
          s.push h
      if s.length
        photo.set 'searchingStores', yes
        sorted = s.sort (a,b) -> if a.get("title") >= b.get("title") then 1 else -1 if s
        filtered = sorted.filter (s) -> !photo.get('instance.stores').has(s)
        console.log filtered
        photo.set "storeSearchResults", new Batman.Set filtered...
      else
        photo.resetSearch node, true
    Frei.CouchStorage.couchView "store_search", {startkey:'"'+$(node).val()+'"', endkey:'"'+$(node).val()+'zzzzz"'}, cb


  resetStoreSearch : (node, keepText) ->
    @set 'searchingStores', no


  storeFilter : (node) ->
    if $(node).val().length == 0 then @resetStoreSearch(node) else @adjustListForStoreSearchNode(node)


  constructor: ->
    super arguments...

    $('ul#storesToAdd li span.addStore').bind 'click', (idx, n) =>
      alert idx
      alert n
      $n = $(n)
      id = $n.attr 'title'
      console.log "ID: #{id}"
      Frei.Stores.find id (err, store) =>
        @get('instance.stores').add store
        console.log @get('instance.stores'), store

  removeStoreAsParent: (n) ->
    $n = $(n)
    id = $n.attr 'title'
    console.log "ID: #{id}"
    Frei.Stores.find id (err, store) =>
      @get('instance.stores').remove store

  addStoreAsParent: (n) ->

