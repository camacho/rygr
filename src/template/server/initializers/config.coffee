_ = require 'underscore'
{config} = require 'rygr-util'
path = require 'path'

module.exports = (app) ->
  # Copy config into app
  rootDir = path.join __dirname, '..', '..', 'config'
  config.initialize ["#{rootDir}/*.json", 'config/*.json']
  config = _.clone config
  app.set key, config[key] for key in Object.keys config

  # Set resolved directories for assets
  dirs =
    base: __dirname
    public: path.resolve __dirname, '..', '..', app.get('client').build.root
    assets: path.resolve __dirname, '..', '..', app.get('client').build.assets

  app.set 'dirs', dirs

  # Set port (if needed)
  app.get('server').port = process.env.PORT if process.env.PORT
