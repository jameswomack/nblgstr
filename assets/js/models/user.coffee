class BB.User extends BB.Model
  @encode 'name', 'password'

  @accessor 'email',
    get: ->
      @get 'id'
    set: (k,v) ->
      @set 'id', v

  @attachment 'picture', {thumb: "80x80>", medium: "260x260>", large: "640x640>"}

  @parentOf 'posts'
  
  @classAccessor 'loginText', ->
    'Login'

  @classAccessor 'current', ->
    user_id = $.cookie().user_id 
    user_id = null if user_id is 'undefined'
    if user_id
      @find $.cookie().user_id, (err, user) => 
        user
    else
      false