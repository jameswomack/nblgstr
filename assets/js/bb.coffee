class @BB extends Batman.App
  @root 'posts#index'

  @resources 'posts'

  @route 'error', "error#index"

  @env = window.node_env

  @__defineGetter__ "routes", ->
    Object.keys(@get('routes')).exclude("_batman","routeMap","args")

$ ->
  BB.run()

  if navigator.geolocation
    setPosition = (position) ->
      BB.set 'location_latitude', position.coords.latitude
      BB.set 'location_longitude', position.coords.longitude

    handleError = (error) ->
      errors =
        1: "Permission denied"
        2: "Position unavailable"
        3: "Request timeout"
      alert "Error: " + errors[error.code]
      BB.set 'location_error', errors[error.code]

    timeoutVal = 10 * 1000 * 1000
    navigator.geolocation.getCurrentPosition setPosition, handleError,
      enableHighAccuracy: true
      timeout: timeoutVal
      maximumAge: 0
  else
    alert "Geolocation is not supported by this browser"
