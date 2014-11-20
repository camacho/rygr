path = require 'path'
serveStatic = require 'serve-static'

module.exports = (app) -> serveStatic app.get('dirs').public, index: false
