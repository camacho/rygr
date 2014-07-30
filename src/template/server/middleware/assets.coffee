path = require 'path'
express = require 'express'

module.exports = (app) -> express.static app.get('dirs').public
