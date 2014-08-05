module.exports = (env, done) ->
  {log, colors, asyncQueue} = require 'rygr-util'
  spawn = require('child_process').spawn

  installLocalNpms = (env, next) ->
    log 'Running `npm install`'
    install = spawn 'npm', ['install'], stdio: 'inherit'

    install.once 'close', (code) ->
      return next new Error '`npm install` failed' if code isnt 0
      log colors.green '`npm install` succeeded'
      next()

  installBowerPackages = (env, next) ->
    log 'Running `bower install`'

    install = spawn 'bower', ['install'], stdio: 'inherit'

    install.once 'close', (code) ->
      return next new Error '`bower install` failed' if code isnt 0
      log colors.green '`bower install` succeeded'
      next()

  asyncQueue [env], [
    installLocalNpms
    installBowerPackages
    (err, env, next) -> log.error err
  ], done
