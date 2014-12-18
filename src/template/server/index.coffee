express = require 'express'
_ = require 'underscore'

# Setup Express app
app = express()

# Call initializers
require('./initializers/index') app

# Start listening
server = app.listen app.get('server').port, ->
  console.log "Server listening on port #{ app.get('server').port }"

# Make sure to shut down the server if the process is terminated
process.on 'SIGTERM', server.close

# Return the server
module.export = server
