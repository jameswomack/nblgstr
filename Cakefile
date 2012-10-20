require "./db"

NG = global.NG
db = NG.db

fs = require "fs"
path = require "path"
CoffeeScript = require "coffee-script"

im = require "imagemagick"
request = require 'request'
sugar = require 'sugar'

# TODO - adding global.Batman in here is actually a bugfix for Batman running in a Cakefile environment
global.Batman = Batman = require 'batman'

task "db:migrate", ->
  db.migrate (err, res) ->
    console.log err if err
    console.log res if res

task "db:delete_projects", ->
  db.temporaryView {
    map: (d) ->
      emit null, d if d.t is "project"
  }, (err, docs) =>
    console.log docs
    docs = ( a.value for a in docs )
    docs.forEach (doc) ->
      console.log doc.t, theType
      doc._deleted = true
    db.save docs, (err) ->
      console.log err if err

seed = (what) ->
  db.reset (err) ->
    if err
      console.log "Failed resetting db", err
      return

    db.migrate (err) ->
      if err
        console.log "Failed db migration", err
        return

      for type, data of require "#{NG.root}/db/#{what}"
        for d in data
          d.t = Batman.helpers.singularize type
        db.save data, (err) ->
          console.log err if err
