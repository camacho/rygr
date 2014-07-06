config = require 'config'
path = require 'path'
express = require 'express'
_ = require 'underscore'

config.initialize? null, override: path.join __dirname, '..', 'config'

middleware = require './middleware/main'

{file} = require 'utils'
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
