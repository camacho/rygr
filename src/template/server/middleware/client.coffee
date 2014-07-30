path = require 'path'
_ = require 'underscore'

module.exports = (app) ->
  pubDir = app.get('dirs').public

  (req, res, next) ->
    if req.accepts('html') and not _(req.path).startsWith '/assets/'
      res.type('html').sendfile path.join pubDir, 'index.html'
    else
      next()
