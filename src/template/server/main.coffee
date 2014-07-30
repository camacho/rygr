{file, config} = require 'bedrock-utils'
path = require 'path'
express = require 'express'
_ = require 'underscore'

config.initialize? ['config/*.json', "#{path.join(__dirname, '..', 'config')}/*.json"]

middleware = require './middleware/main'

initializerOptions = extension: path.extname __filename
file.requireDirectory path.join(__dirname, 'initializers'), initializerOptions

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
