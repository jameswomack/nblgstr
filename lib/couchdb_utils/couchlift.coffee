module.exports = class CouchLift


  fs = require 'fs'
  path = require 'path'
  mime = require 'mime'
  request = require 'request'
  require 'sugar'

  _base = "#{__dirname}/files"

  @directoryToSparksWithAttachments = =>
    processDirectory "#{_base}/#{n}" if fs.statSync("#{_base}/#{n}").isDirectory() for n in fs.readdirSync _base

  @uploadAudioSparks = (newDir, theDBName) =>
    theDBName = 'px' if typeof theDBName is 'undefined' #TODO - DRY theDBName everywhere in this file
    @lessonsDir = "#{__dirname}/../audio/"
    dir = @lessonsDir+newDir
    if fs.statSync(dir).isDirectory()
      list = fs.readdirSync(dir).filter (n) ->
        file = path.join(dir, n)
        (path.basename(file)[0] isnt "." and path.basename(file).substring(0,4) isnt "Icon" and fs.statSync(file).isFile())
      list.forEach (name) =>
        file = path.join(dir, name)
        _currentObject = {t: 'spark', _attachments: {}, legacy_name: file, folder: newDir}
        console.log "Processing file at path #{file}"
        processFile file, (_aPath,v) =>
          console.log name
          _currentObject._attachments[name] = v
        save _currentObject, theDBName

  processDirectory = (aPath, anObject, theDBName) =>
    anObject ?= {}
    theDBName ?= 'px'
    _currentObject = Object.merge {t: 'spark', _attachments: {}}, anObject
    console.log "Processing directory at path #{aPath}"

    _cb = (_aPath,v) =>
      _filename = _aPath.replace(aPath+'/','').split('.')[0]
      if _filename.length
        _attachmentName = "#{v.content_type.split('/')[0]}/#{_filename}"
        console.log _attachmentName
        _currentObject._attachments[_attachmentName] = v

    processFile "#{aPath}/#{n}",_cb for n in fs.readdirSync aPath
    save _currentObject, theDBName


  save = (anObject, theDBName) =>
    theDBName ?= 'px'
    request {method: 'POST', url : "http://localhost:5984/#{theDBName}", json : anObject}, (err, resp, body) ->
      console.error err if err
      console.log body


  processFile = (aPath, aCallback) =>
    return if fs.statSync(aPath).isDirectory()
    console.log "Processing file at path #{aPath}"

    _contentType = mime.lookup aPath
    _data = if path.existsSync aPath then fs.readFileSync aPath, 'base64' else {error: aPath}

    aCallback aPath, {content_type: _contentType, data: _data}
