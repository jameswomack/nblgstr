class Frei.User extends Frei.Model
  @encode 'name', 'password'

  @accessor 'email',
    get: ->
      @get 'id'
    set: (k,v) ->
      @set 'id', v

  @attachment 'picture', {thumb: "80x80>", medium: "260x260>", large: "640x640>"}

  @parentOf 'stores'