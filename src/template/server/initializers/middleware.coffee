module.exports = (app) ->
  app.use require('../middleware/assets') app
  app.use require('compression')()
  app.use require('../middleware/client') app
  app.use require('../middleware/missing') app
  app.use require('../middleware/error') app
