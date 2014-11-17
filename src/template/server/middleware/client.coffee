_ = require 'underscore'

module.exports = (app) ->
  (req, res, next) ->
    if req.accepts('html') and not _(req.path).startsWith '/assets/'
      res.render 'client'
    else
      next()
