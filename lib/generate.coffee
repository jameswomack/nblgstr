#!/usr/bin/env coffee

# coffee ./lib/generate.coffee AppName model

[cs,file,appName,modelName] =  process.argv
fs = require 'fs'
sugar = require 'sugar'
global.Batman = Batman = require 'batman'

Batman.helpers.classify = (string) ->
  titlelized = Batman.helpers.capitalize(string.replace(/_/,' ')).replace( " ", '' )
  Batman.helpers.singularize titlelized

pathMake = (aPath) -> "#{__dirname}/../#{aPath}"
assetsPathMake = (aPath) -> pathMake "assets/#{aPath}"
dbPathMake = (aPath) -> pathMake "db/#{aPath}"
viewsPathMake = (aPath) -> assetsPathMake "views/#{aPath}"
jsPathMake = (aPath) -> assetsPathMake "js/#{aPath}"

contentMake = (className, type) -> "class #{appClassName}.#{className} extends #{appClassName}.#{Batman.helpers.capitalize(type)}\n"

modelName = modelName.toLowerCase()
designFilePath = dbPathMake "design.coffee"
appFileName = "#{appName.toLowerCase()}.coffee"
appClassName = Batman.helpers.classify(appName)
modelClassName = Batman.helpers.classify(modelName)
modelFileName = "#{modelName}.coffee"
folderName = Batman.helpers.pluralize(modelName)
controllerClassName = "#{Batman.helpers.capitalize(folderName)}Controller"
controllerFileName = "#{folderName}_controller.coffee"
appFilePath = jsPathMake "#{appFileName}"
modelPath = jsPathMake "models/#{modelFileName}"
controllerPath = jsPathMake "controllers/#{controllerFileName}"
viewFolderPath = viewsPathMake "#{folderName}"
modelContent = contentMake modelClassName, 'model'
controllerContent = contentMake controllerClassName, 'controller'

viewFolderPathMake = (name) -> "#{viewFolderPath}/#{name}.jade"

fs.writeFile modelPath, modelContent, (err) ->
  if err
    console.log err
  else
    console.log "The model #{modelClassName} was created!"

fs.writeFile controllerPath, controllerContent, (err) ->
  if err
    console.log err
  else
    console.log "The controller #{controllerClassName} was created!"

fs.mkdir viewFolderPath, (ex) ->
  if ex
    console.log ex
  else
    for n in ['index','edit','show','new']
      do (n) ->
        fs.writeFile viewFolderPathMake(n), "extends ../_blocks/_#{n}", (err) ->
          if err
            console.log err
          else
            console.log "The view #{n} was created!"

fs.readFile appFilePath, (err, data) ->
    if err
      console.log err
    else
      data = data.toString()
      array = data.split '  @resources'
      array.add " '#{folderName}'\n", 1
      data = array.join '  @resources'
      fs.writeFile appFilePath, data, (err) ->
        if err
          console.log err
        else
          console.log "The resource #{folderName} was added to the app file!"

fs.readFile designFilePath, (err, data) ->
    if err
      console.log err
    else
      data = data.toString()
      array = data.split 'module.exports = design'
      array.add "design.views.#{modelName}_search = {\n  map: (d) ->\n    emit d.title, d._id if d.t is '#{modelName}'\n}\n", 1
      array = array.to 2
      array.add 'module.exports = design'
      data = array.join ''
      fs.writeFile designFilePath, data, (err) ->
        if err
          console.log err
        else
          console.log "The view #{modelName}_search was added to the design file!"
