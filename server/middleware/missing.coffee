path = require 'path'

module.exports = (app) ->
  (req, res, next) ->
    res.status 404

    if req.is('json') or
    path.extname(req.path) is '.json' or
    req.accepts 'application/json'
      res.type('json').send error: 'Page not found'
    else if req.accepts 'html'
      res.redirect '/404'
    else
      res.type('txt').send 'Page not found'
