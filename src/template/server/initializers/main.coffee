module.exports = (app) ->
  require './underscore'
  require('./config') app
  require('./views') app
  require('./middleware') app
