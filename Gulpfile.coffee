# ------------------------------------------------------------------------------
# Load in modules
# ------------------------------------------------------------------------------
gulp = require 'gulp'
$ = require('gulp-load-plugins')()

runSequence = require 'run-sequence'

ENV = process.env.NODE_ENV or 'development'
{config} = require 'bedrock-utils'
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
gulp.task 'compile', (cb) ->
  src = ["#{ config.build.src }/**", "!#{ config.build.src }/template/**"]
  coffeeFilter = $.filter '**/*.coffee'

  gulp.src(src)
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.build.dest)
    .pipe(coffeeFilter)
    .pipe($.coffeelint optFile: './.coffeelintrc')
    .pipe($.coffeelint.reporter())
    .pipe($.coffee bare: true)
    .pipe(coffeeFilter.restore())
    .pipe(gulp.dest config.build.dest)
    .on 'end', ->
      files = [
        "#{ config.build.src }/template/**"
        "#{ config.build.src }/template/**/.gitignore"
        "#{ config.build.src }/template/.bowerrc"
        "#{ config.build.src }/template/.coffeelintrc"
      ]
      gulp.src(files)
        .pipe(gulp.dest "#{ config.build.dest }/template")
        .on 'end', cb

  null

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
      sequence = ['clean', 'compile']
      sequence.push "bump:#{ type }" if type
      sequence.push ->
        spawn = require('child_process').spawn
        spawn('npm', ['publish'], stdio: 'inherit').on 'close', cb

      runSequence sequence...

  for type, index in types
    gulp.task "bump:#{ type }", bump type
    # gulp.task "publish:#{ type }", publish type

  gulp.task 'bump', bump 'patch'
  # gulp.task 'publish', publish()
)()

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', (cb) ->
  gulp.watch "#{ config.build.src }/**", ['compile']
  cb()

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', ->
  runSequence 'clean', 'compile', 'watch'
