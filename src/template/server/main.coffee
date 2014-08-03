{file, config} = require 'rygr-util'
path = require 'path'
express = require 'express'
_ = require 'underscore'
require('./initializers/main')()

paths = ['config/*.json', "#{path.join(__dirname, '..', 'config')}/*.json"]
config.initialize? paths

middleware = require './middleware/main'

app = express()

# Setup directories
dirs =
  base: __dirname
  public: path.resolve __dirname, '..', config.client.build.root
  assets: path.resolve __dirname, '..', config.client.build.assets

app.set 'dirs', dirs

# Set middleware
middleware app

server = app.listen config.server.port, ->
  console.log "Server listening on port #{ config.server.port }"

process.on 'SIGTERM', server.close

module.export = server
