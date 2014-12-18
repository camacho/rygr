_ = require 'underscore'
path = require 'path'

module.exports = (app) ->
  # Copy config into app
  config = require path.join __dirname, '..', '..', 'config', 'index'
  app.set key, config[key] for key in Object.keys config

  # Set resolved directories for assets
  dirs =
    base: __dirname
    public: path.resolve __dirname, '..', '..', app.get('client').build.public
    assets: path.resolve __dirname, '..', '..', app.get('client').build.assets

  app.set 'dirs', dirs

  # Set port (if needed)
  app.get('server').port = process.env.PORT if process.env.PORT
