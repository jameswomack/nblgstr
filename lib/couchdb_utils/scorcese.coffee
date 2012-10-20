class Scorcese


  fs = require 'fs'
  path = require 'path'
  mime = require 'mime'
  request = require 'request'
  require 'sugar'

  _base = "#{__dirname}/key"


  @direct = ->
    processDirectories()


  processDirectories = =>
    processDirectory "#{_base}/#{n}" if fs.statSync("#{_base}/#{n}").isDirectory() for n in fs.readdirSync _base


  processDirectory = (aPath) =>
    _keynote = aPath.replace "#{_base}/", ''
    _currentObject = {t: 'spark', keynote: _keynote, _attachments: {}, pages: []}
    console.log "Processing directory at path #{aPath}"

    _cb = (aPath,v) =>
      _attachmentName = aPath.replace "#{_base}/#{_currentObject.keynote}/#{_currentObject.keynote}.", ''
      _indexPath = _attachmentName.split('-')
      _currentPage = Number(_indexPath[0])-1
      _currentObject.pages[_currentPage] ?= []
      _currentTransition = Number(_indexPath[1])-1
      _currentObject.pages[_currentPage].add _attachmentName, _currentTransition
      _currentObject._attachments[_attachmentName] = v


    processFile "#{aPath}/#{n}",_cb for n in fs.readdirSync aPath
    save _currentObject


  save = (anObject) =>
    request {method: 'POST', url : "http://localhost:5984/px", json : anObject}, (err, resp, body) ->
      console.error err if err
      console.log body


  processFile = (aPath, aCallback) =>
    return if fs.statSync(aPath).isDirectory()
    return if !aPath.split('.').count('jpg')
    console.log "Processing file at path #{aPath}"

    _contentType = mime.lookup aPath
    _data = if path.existsSync aPath then fs.readFileSync aPath, 'base64' else {error: aPath}

    aCallback aPath, {content_type: _contentType, data: _data}



Scorcese.direct()