class Frei.LoginForm extends Batman.View
  constructor: ->
    super arguments...

    @set 'emailField', $("input#email")

    @set 'passwordField', $("input#password")

    @set 'registeringSwitch', $("input#registering")
    @get('registeringSwitch').on "change", (event) =>
      @get('registeringSwitch')


  @wrapAccessor 'registered', (core) ->
    get: (key) ->
      value = core.get.call(@, key)
      if value then value else no


  @wrapAccessor 'loggedIn', (core) ->
    get: (key) ->
      value = core.get.call(@, key)
      if value then value else no


  @accessor 'registering',
    get: ->
      (@get('registeringSwitch').is(':checked'))


  @accessor 'showLoginForm', ->
    get: ->
      @get('loggedIn') and @get('registered')


  @accessor 'email', ->
    get: ->
      @get('emailField').val()


  @accessor 'password', ->
    get: ->
      @get('passwordField').val()


  handleUser: (n, e) ->
    Frei.User.find @get('params.id').val(), (e, user) =>
      if e
        console.error e
      else
        if user
          if @get('registering')
            @set 'registrationStatus', 'User exists'
          else
            @set "user", user
            @set "loggedIn", yes
            @set 'loginStatus', 'Logged in'
            @set 'showLoginForm', no
        else
          if @get('registering')
            @set 'registrationStatus', 'Creating user...'
            user = new Frei.User(id: @get('username'), password: @get('password'))
            user.save (e) =>
              if e
                @set 'registrationStatus', 'Create user failed'
              else
                @set 'registrationStatus', 'Create user succeeded'
                @set 'showLoginForm', no
          else
            @set 'loginStatus', 'Logged failed'

