class Frei.NominatumMessenger
  @coordinatesFromStreetAndCity: (street, city, state, cb, ecb) ->
    $.get "http://nominatim.openstreetmap.org/search?street=#{street}&city=#{city}&state=#{state}&format=json", (o) ->
      if o.length
        cb o[0].lat, o[0].lon
      else
        ecb()