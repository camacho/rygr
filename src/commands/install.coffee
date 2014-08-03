module.exports = (env, handleError, done) ->
  {log, colors, asyncQueue} = require 'rygr-util'
  shell = require 'shelljs'

  installLocalNpms = (env, next) ->
    log 'Running `npm install`'
    shell.exec 'npm install', (code) ->
      return next new Error '`npm install` failed' if code isnt 0
      log colors.green '`npm install` succeeded'
      next()

  installBowerPackages = (env, next) ->
    log 'Running `bower install`'

    shell.exec 'bower install', (code) ->
      return next new Error '`bower install` failed' if code isnt 0
      log colors.green '`bower install` succeeded'
      next()

  asyncQueue [env], [
    installLocalNpms
    installBowerPackages
    handleError
  ], done
