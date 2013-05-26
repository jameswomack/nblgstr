class Frei.Model extends Batman.Model
  @persist Frei.CouchStorage
  @primaryKey: "_id"
  @encode "_rev",'_attachments','created_time','updated_time'

  @classAccessor 'resourceName', -> @name

  @::valid = ->
    keys = Array::slice.call arguments
    for k in keys
      if !@get(k)?.length or @get(k) is 'Invalid Date'
        return false
    return true

  constructor: ->
    super arguments...
    if @constructor.__attachment_styles
      @set '_attachment_styles', @constructor.__attachment_styles

  @include_attachments: ->
    @encode '_attachments',
      _refer = @
      decode: (value, key, incomingJSON, outgoingObject, record) ->
        a = attr:{}
        for k, v of incomingJSON._attachments when k.indexOf 'gen/' is 0
          do (k, v)->
            [ attr, name, style ] = k.split '/'
            style = style.replace /\..*/, ''
            a.attr[name] ?= {}
            a.attr[name][style] = v
            a.attr[name][style].filename = k
            _refer.accessor name,
              get: ->
                pic = @get('_attachments').attr[name]?.original
                return "/att/#{@get 'id'}/#{pic.filename}.#{pic.digest}.#{MimeTypes.ext pic.content_type}" if pic and pic.filename
                @["_#{name}"]
        a

  @attachment: (attr_name, styles) ->
    @encode '_attachment_styles'
    a = @__attachment_styles ?= {}
    a[attr_name] = styles

    @accessor attr_name,
      get: ->
        if pic = @get('_attachments')?.attr?[attr_name]?.original
          if pic.filename
            "/img/#{@get 'id'}/#{pic.filename}.#{pic.digest}.#{MimeTypes.ext pic.content_type}"
          else
            @["_#{attr_name}"]

      set: (k, v) ->
        a = @get('_attachments') ? @set '_attachments', { attr: {} }
        a.attr[k] = original: v
        @["_#{attr_name}"] = "data:#{v.content_type};base64,#{v.data}"

    Object.extended(styles).keys().each (style) =>
      do(style) =>
        @accessor "#{attr_name}_#{style}",
          get: ->
            if pic = @get('_attachments')?.attr?[attr_name]?[style]
              "/img/#{@get 'id'}/#{pic.filename}.#{pic.digest}.#{MimeTypes.ext pic.content_type}"

    @encode '_attachments',
      decode: (value, key, incomingJSON, outgoingObject, record) ->
        a = attr:{}
        for k, v of incomingJSON._attachments when k.indexOf 'attr/' is 0
          [ attr, name, style ] = k.split '/'
          style = style.replace /\..*/, ''
          a.attr[name] ?= {}
          a.attr[name][style] = v
          a.attr[name][style].filename = k
        a

      encode: (value, key, builtJSON, record) ->
        a = {}
        for k, v of value.attr
          for kk, vv of v
            a["attr/#{k}/#{kk}"] = vv
        a


  @encode : ->
    @__defineGetter__ "type", ->
      @.toString().split('function ')[1].split('() {')[0].toLowerCase()
    for argIndex of arguments
      key = arguments[argIndex]
      if Batman.typeOf key is "String"
        Batman.Model._keys ?= []
        Batman.Model._keys[@type] ?= []
        Batman.Model._keys[@type].push key unless Batman.contains Batman.Model._keys[@type], key
    super

  @allKeys : ->
    Batman.Model._keys[@type]

  @all: (args..., cb) ->
    set = new Batman.Set
    @load args..., (err,res) =>
      if !err
        set.add res...
      cb err, set
    set

  @childOf : (relation)->
    parent = Batman.helpers.underscore( relation )
    objectType = Batman.helpers.singularize( parent )
    resourceName = @::constructor.get('resourceName').toLowerCase()
    singularResourceName = Batman.helpers.singularize resourceName
    singular = parent == objectType
    field_name = "p_#{objectType}"
    unless singular
      @encode relation,
        encode: (v, k, obj, r)->
          obj[field_name] = v.toArray().map (p)->
            if p._id? then p else {_id: p.get('id')}
          r.fromJSON obj
          return

    @encode field_name,
      encode: (v, k, jsonObj, r)->
        return v if singular

    @accessor relation,
      set : (k, v) ->
        resourceName = Batman.helpers.pluralize resourceName unless v?.get?(resourceName)?
        if singular
          if Batman.typeOf(v) is 'Set'
            throw new Frei.DevelopmentError "Singular relations require a Batman.Object, Batman.Set given."
          else if v.get?(singularResourceName) and v.get?(singularResourceName).length > 0
            throw new Frei.DevelopmentError "Parent model should not have more than 1 children associated."
          parent_data = if (Batman.typeOf(v) == 'String') then {_id: v} else {_id: v.get('id')}
        else
          parent_data = v
        v.get(resourceName).add @ if v.get?(resourceName)
        @set field_name, parent_data
      get: (k) ->
        parentObj = Frei[ Batman.helpers.classify(objectType) ]
        if singular
          return null unless @get(field_name)?
          parentObj.find @get(field_name)._id, (err, result) -> result
        else
          parentObj.all view: 'parents', key: [ objectType, @get('id') ],  (err, results) -> results
      unset : ->
        @unset field_name

  @parentOf : (relation)->
    objectType = Batman.helpers.singularize( relation )
    resourceName = @::constructor.get('resourceName').toLowerCase()
    singular = objectType == relation
    field_name = "p_#{objectType}"

    unless singular
      @::on 'save', ->
        @get(relation).forEach (r)=>
          if r.get(resourceName) is undefined
            r.get( Batman.helpers.pluralize(resourceName) ).add {_id: @get('id')}
          else
            r.set resourceName, @
          r.save()

    @accessor relation,
      set : (k, v)->
        throw new Frei.DevelopmentError "need to save first" if !@get('id')
        if singular
          related = @get(relation)
          related.on 'change', (r)->
            throw new Frei.DevelopmentError "Model should not have more than 1 children associated." if r and r.length > 0
            v.set resourceName, @
            v.save()
      get : ->
        throw new Frei.DevelopmentError "need to save first" if !@get('id')
        Frei[ Batman.helpers.classify(objectType) ].all view: 'children', key: [ objectType, @get('id') ],  (err, results) ->
          results
      unset : ->
        @unset field_name
