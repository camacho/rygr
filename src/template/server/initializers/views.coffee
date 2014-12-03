path = require 'path'

module.exports = (app) ->
  app.set 'views', path.join __dirname, '..', 'views'
  app.set 'view engine', 'jade'
  
  app.locals.livereload = port: app.get('livereload').port
  app.locals.requirejs = JSON.stringify app.get 'requirejs'
