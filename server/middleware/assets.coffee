path = require 'path'
express = require 'express'

module.exports = (app) ->
  dir: '/assets'
  method: express.static app.get('dirs').assets
