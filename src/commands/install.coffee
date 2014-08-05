module.exports = (options, done) ->
  {log, colors, asyncQueue} = require 'rygr-util'
  spawn = require('child_process').spawn

  installLocalNpms = (options, next) ->
    log 'Running `npm install`'
    install = spawn 'npm', ['install'], stdio: 'inherit'

    install.once 'close', (code) ->
      return next new Error '`npm install` failed' if code isnt 0
      log colors.green '`npm install` succeeded'
      next()

  installBowerPackages = (options, next) ->
    log 'Running `bower install`'

    install = spawn 'bower', ['install'], stdio: 'inherit'

    install.once 'close', (code) ->
      return next new Error '`bower install` failed' if code isnt 0
      log colors.green '`bower install` succeeded'
      next()

  asyncQueue [options], [
    installLocalNpms
    installBowerPackages
    (err, options, next) -> log.error err
  ], done
