class @Frei extends Batman.App
  @root 'projects#index'

  @resources 'stores'
  @resources 'photos'
  @resources 'projects'

  @route 'error', "error#index"

  @env = window.node_env

  @__defineGetter__ "routes", ->
    Object.keys(@get('routes')).exclude("_batman","routeMap","args")

$ ->
  Frei.run()
