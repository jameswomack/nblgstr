global.NG = NG ?= {}

path = require 'path'
NG.root = path.normalize "#{__dirname}/.."

NG.env = process.env["NODE_ENV"] || "development"

