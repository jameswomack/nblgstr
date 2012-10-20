fs = require("fs")
path = require('path')

module.exports = class Robin

  constructor : (@options) ->

  fs.mkdirRecursively = (dirPath, mode, callback) ->
    fs.mkdir dirPath, mode, (error) ->
      if error and error.errno is 34
        fs.mkdirRecursively path.dirname(dirPath), mode, callback
        fs.mkdirRecursively dirPath, mode, callback
      callback and callback(error)

  uploadFile : (req, res, next) ->
    next()

  uploadResponse: (req, res) ->
    retVal = JSON.stringify(
      filename: req.files.undefined.path.split('/').slice(-1)[0]
      path: @options.upload_dir)
    res.send retVal

  saveBase64: (base64Data, savePath, filename) ->
    pngRegExp = /^data:image\/png;base64,/
    throw new Error 'Base64 not PNG' if base64Data.match(pngRegExp).length is 0
    dataBuffer = new Buffer(base64Data.replace(pngRegExp, ""), "base64")
    saveFolder = path.join(@options.upload_dir, '../'+savePath)
    fs.mkdirRecursively saveFolder, undefined, ->
      fs.writeFile path.join(saveFolder, filename), dataBuffer, (err) -> console.error err

  class : (pathToAccessClassFrom) ->
    require pathToAccessClassFrom

  instance : (pathOfClassToCreateInstanceFrom) ->
    (new (@class pathOfClassToCreateInstanceFrom)())

  classToString : (Class) ->
    [ Class, '' ].join('').split('(')[0].split('function ')[1]
