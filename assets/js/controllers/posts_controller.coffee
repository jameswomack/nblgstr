class BB.PostsController extends BB.Controller
  show: ->
    super arguments...
    (=>
      coordinate = [@get('post.location_latitude'), @get('post.location_longitude')]
      map = L.map('map').setView(coordinate, 13)
      L.tileLayer('http://{s}.tile.cloudmade.com/05afaa8abaa74deaabbf7c99e68bc716/997/256/{z}/{x}/{y}.png', {
          attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
          maxZoom: 18
      }).addTo(map)
      marker = L.marker(coordinate).addTo(map)
      marker.bindPopup("<strong>#{@get('post.location_name')}</strong>").openPopup()
      img = document.getElementById("picture").firstChild
      if img.height > img.width
        img.height = "100%"
        img.width = "auto"
    ).delay 1000