path = require 'path'

module.exports = (app) ->
  (error, req, res, next) ->
    res.status 500

    if req.is('json') or
    path.extname(req.path) is '.json' or
    req.accepts 'application/json'
      res.type('json').send error: 'Server error'
    else if req.accepts 'html'
      res.redirect '/500'
    else
      res.type('txt').send 'Server error'
