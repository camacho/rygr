# ------------------------------------------------------------------------------
# Load in modules
# ------------------------------------------------------------------------------
gulp = require 'gulp'
$ = require('gulp-load-plugins')()

runSequence = require 'run-sequence'

ENV = process.env.NODE_ENV or 'development'
{config} = require 'rygr-util'
config.initialize 'config/*.coffee', debug: true

# ------------------------------------------------------------------------------
# Custom vars and methods
# ------------------------------------------------------------------------------
alertError = $.notify.onError (error) ->
  message = error?.message or error?.toString() or 'Something went wrong'
  "Error: #{ message }"

# ------------------------------------------------------------------------------
# Directory management
# ------------------------------------------------------------------------------
gulp.task 'clean', ->
  gulp.src("#{ config.build.dest }/*", read: false)
    .pipe($.plumber errorHandler: alertError)
    .pipe $.rimraf force: true

# ------------------------------------------------------------------------------
# Compile
# ------------------------------------------------------------------------------
gulp.task 'copy template', ->
  src = [
    'config/**'
    'client/src/**'
    'server/**'
    '*'
    '.bowerrc'
    '.coffeelintrc'
    '.gitignore'
  ]

  options =
    cwd: "#{ config.build.src }/template"
    base: "#{ config.build.src }/template"

  gulp.src(src, options )
    .pipe($.plumber errorHandler: alertError)
    .pipe(gulp.dest "#{ config.build.dest }/template")

gulp.task 'compile', ->
  gulp.src([
    "#{ config.build.src }/*.coffee"
    "#{ config.build.src }/{bin,commands}/**/*.coffee"
  ])
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.build.dest)
    .pipe($.coffeelint optFile: './.coffeelintrc')
    .pipe($.coffeelint.reporter())
    .pipe($.coffee bare: true)
    .pipe(gulp.dest config.build.dest)

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'build', (cb) ->
  runSequence 'clean', ['compile', 'copy template'], cb

# ------------------------------------------------------------------------------
# Release
# ------------------------------------------------------------------------------
(->
  types = [
    'prerelease'
    'patch'
    'minor'
    'major'
  ]

  bump = (type) ->
    ->
      gulp.src('./package.json')
        .pipe($.bump type: type)
        .pipe(gulp.dest './')

  publish = (type) ->
    (cb) ->
      sequence = ['build']
      sequence.push "bump:#{ type }" if type
      sequence.push ->
        spawn = require('child_process').spawn
        spawn('npm', ['publish'], stdio: 'inherit').on 'close', cb

      runSequence sequence...

  for type, index in types
    gulp.task "bump:#{ type }", bump type
    gulp.task "publish:#{ type }", publish type

  gulp.task 'bump', bump 'patch'
  gulp.task 'publish', publish()
)()

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', (cb) ->
  gulp.watch [
    "#{ config.build.src }/*.coffee"
    "#{ config.build.src }/{bin,commands}/**/*.coffee"
  ], ['compile']

  cb()

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', (cb) ->
  runSequence 'build', 'watch', cb
