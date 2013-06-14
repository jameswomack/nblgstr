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
viewsPathMake = (aPath) -> assetsPathMake "views/#{aPath}"
jsPathMake = (aPath) -> assetsPathMake "js/#{aPath}"

appClassName = Batman.helpers.classify(appName)

contentMake = (className, type) -> "class #{appClassName}.#{className} extends #{appClassName}.#{Batman.helpers.capitalize(type)}\n"

appFileName = "#{appName.toLowerCase()}.coffee"
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
  console.log ex
  if !ex?
    for n in ['index','edit','show','new']
      do (n) ->
        fs.writeFile viewFolderPathMake(n), '', (err) ->
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
