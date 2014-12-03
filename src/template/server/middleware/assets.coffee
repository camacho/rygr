path = require 'path'
assets = require 'connect-gzip-static'

maxAge = 100*60*60*24 # 1 day

module.exports = (app) ->
  assets app.get('dirs').public, index: false, maxAge: maxAge
