class Frei.HomeController extends Frei.Controller
  index: ->
    super arguments...

    Frei.on 'ready', =>
      @set 'showLoginForm', yes if !@get('loggedIn')

      @set 'emailField', $("input#emailField")

      @set 'passwordField', $("input#passwordField")

      @set 'registeringSwitch', $("input#registeringSwitch")

      @get('registeringSwitch').on "change", (event) =>
        @set 'registering', @get('registeringSwitch').is(':checked')


  @wrapAccessor 'registered', (core) ->
    get: (key) ->
      value = core.get.call(@, key)
      if value then value else no


  @wrapAccessor 'loggedIn', (core) ->
    get: (key) ->
      value = core.get.call(@, key)
      if value then value else no


  handleUser: (n, e) ->
    return unless @get('emailField')?
    Frei.User.find @get('emailField').val(), (e, user) =>
      if e and e.request.status isnt 404
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
            user = new Frei.User()
            user.set 'id', @get('emailField').val()
            user.set 'password', @get('passwordField').val()
            user.save (e) =>
              if e
                @set 'registrationStatus', 'Create user failed'
              else
                @set 'registrationStatus', 'Create user succeeded'
                @set 'showLoginForm', no
                @set "registered", yes
          else
            @set 'loginStatus', 'Logged failed'

