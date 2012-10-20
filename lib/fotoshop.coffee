class FileInfo
  constructor : (@path) ->
    @mime = require('mime').lookup @path
    @format = global.MimeTypes.ext @mime

module.exports = class Fotoshop
  Size = (w, h) -> width: w, height: h

  @crop: (theFileInfo, theSize, cb) ->
    process.on 'uncaughtException', (err) =>
      console.error "uncaughtException in Fotoshop: #{err}"
      process.removeAllListeners 'uncaughtException'
      cb err
    (require 'imagemagick').crop {
      srcPath: theFileInfo.path,
      srcFormat: theFileInfo.format,
      format: theFileInfo.format,
      width: theSize.width,
      height: "#{theSize.height}^",
      dstPath: '-',
    }, (err, stdout, stderr) => cb err, stdout, theFileInfo.mime

  @square: (aPath, theSize, cb) ->
    @crop new FileInfo(aPath), Size(theSize,theSize), cb

  @fit: (aPath, theWidth, theHeight, cb) ->
    @crop new FileInfo(aPath), Size(theWidth,theHeight), cb