class @Frei extends Batman.App
  @root 'stores#index'

  @resources 'users'
  @resources 'stores'

  @route 'home', "home#index"
  @route 'error', "error#index"

  @env = window.node_env

  @__defineGetter__ "routes", ->
    Object.keys(@get('routes')).exclude("_batman","routeMap","args")

$ ->
  Frei.run()
