class BB.Post extends BB.Model
  @encode 'title', 'body', 'location_name', 'location_latitude', 'location_longitude', 'location_error'

  @accessor  'location_latitude',
    get: ->
      BB.get 'location_latitude'

  @accessor  'location_longitude',
    get: ->
      BB.get 'location_longitude'

  @accessor  'location_error',
    get: ->
      BB.get 'location_error'

  @attachment 'picture', {thumb: "80x80>", medium: "260x260>"}
  
  save: ->
    console.log arguments
    @set 'user', BB.User.get('current')
    super arguments...
  
  @childOf 'user'


