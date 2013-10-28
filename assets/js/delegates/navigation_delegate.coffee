class Frei.NavigationDelegate
  errors:
    1: "Permission denied"
    2: "Position unavailable"
    3: "Request timeout"

  unsupported: "Geolocation is not supported by this browser"

  timeoutVal: 100000000

  handleError: (error) ->
    alert "Error: " + @errors[error.code]
    Frei.set 'location_error', @errors[error.code]

  setPosition: (position) ->
    Frei.set 'location_latitude', position.coords.latitude
    Frei.set 'location_longitude', position.coords.longitude

  constructor: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition @setPosition, @handleError,
        enableHighAccuracy: true
        timeout: @timeoutVal
        maximumAge: 0
    else
      alert @unsupported