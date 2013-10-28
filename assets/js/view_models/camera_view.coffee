class BB.CameraView extends Batman.View
  _key = undefined

  constructor: (options) ->
    _key = Object.keys(options)[0]
    super arguments...
    @input = $('<input type="file">')

  @accessor 'supportsFileInput',
    get: ->
      !@input.disabled

  showFileDialog: (n, e) ->
    @input.on "change", (theEvent) =>
      _file = theEvent.target.files[0]
      _formData = new FormData
      _formData.append 'picture', _file
      $.ajax
        url: "/upload"
        type: "POST"
        data: _formData
        cache: false
        contentType: false
        processData: false
        error: (data) =>
          console.error data
        success: (data) =>
          #https://github.com/rsms/node-imagemagick/issues/60
          if data.error then alert 'Unable to parse image. Please choose another.' else @setPicture data
        complete: =>
          @input.off()
    @input.click()

  setPicture: (image) ->
    @set "#{_key}.picture", image

  showiOSCamera: ->
    window.location.href = 'brilliant://camera'
    Brilliant.baseCallback = (image) =>
      image = JSON.parse image if Batman.typeOf image == 'String'
      @setPicture image
