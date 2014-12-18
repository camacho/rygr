helmet = require 'helmet'

module.exports = (app) ->
  app.use helmet.crossdomain()
  app.use helmet.ieNoOpen()
  app.use helmet.noSniff()
  app.use helmet.frameguard 'deny'
  app.use helmet.xssFilter setOnOldIE: true
  app.use helmet.noCache noEtag: true if app.get('env') is 'development'
  app.use require('../middleware/assets') app
  app.use require('compression')()
  app.use require('../middleware/client') app
  app.use require('../middleware/missing') app
  app.use require('../middleware/error') app
