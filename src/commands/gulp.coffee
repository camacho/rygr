module.exports = (env, done) ->
  {log, colors, asyncQueue} = require 'rygr-util'
  spawn = require('child_process').spawn

  removeListeners = ->
    gulp.stdout.removeListener 'data', listenForServerStart
    gulp.removeListener 'close', handleClose

  handleClose = (code) ->
    removeListeners()
    if code isnt 0
      return next new Error 'Gulp failed to compile and run correctly'

  listenForServerStart = (data) ->
    if data.toString() is 'Server listening on port 8888\n'
      removeListeners()
      require('open') 'http://localhost:8888'

      console.log colors.green 'server started'
      done()

  gulp = spawn 'gulp'
  gulp.stdout.pipe process.stdout, end: false
  gulp.stderr.pipe process.stderr
  gulp.once 'close', handleClose
  gulp.stdout.on 'data', listenForServerStart
