path = require 'path'
_ = require 'underscore'

module.exports = (app) ->
  assetsDir = "/#{path.basename app.get('client').build.assets}/"

  (req, res, next) ->
    if req.accepts('html') and not _(req.path).startsWith assetsDir
      res.render 'client'
    else
      next()
