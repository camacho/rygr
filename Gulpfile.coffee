# ------------------------------------------------------------------------------
# Load in modules
# ------------------------------------------------------------------------------
gulp = require 'gulp'
$ = require('gulp-load-plugins')()

runSequence = require 'run-sequence'
path = require 'path'
fs = require 'fs'
_ = require 'underscore'

ENV = process.env.NODE_ENV or 'development'
(config = require 'config').initialize()

# ------------------------------------------------------------------------------
# Custom vars and methods
# ------------------------------------------------------------------------------
alertError = $.notify.onError (error) ->
  message = error?.message or error?.toString() or 'Something went wrong'
  "Error: #{ message }"

ensureDir = (dir, cb) ->
  fs.mkdirSync dir unless fs.existsSync dir
  cb null

cleanDir = (dir) ->
  gulp.src("#{ dir }/*", read: false)
    .pipe($.plumber errorHandler: alertError)
    .pipe $.clean force: true

# ------------------------------------------------------------------------------
# Directory management
# ------------------------------------------------------------------------------
gulp.task 'clean build', cleanDir.bind null, config.client.build.root
gulp.task 'ensure build dir', ensureDir.bind null, config.client.build.root

# ------------------------------------------------------------------------------
# Copy static
# ------------------------------------------------------------------------------
gulp.task 'copy static', ->
  gulp.src("#{ config.client.src.static }/**")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.root)
    .pipe gulp.dest config.client.build.root

gulp.task 'copy bower', ->
  $.bowerFiles().pipe gulp.dest config.client.build.assets

# ------------------------------------------------------------------------------
# Compile assets
# ------------------------------------------------------------------------------
gulp.task 'scripts', ->
  map = true
  dest = config.client.build.assets

  coffeeFilter = $.filter '**/*.coffee'

  gulp.src("#{ config.client.src.scripts }/**")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed dest)
    .pipe($.preprocess context: ENV: ENV)
    .pipe(coffeeFilter)
    .pipe($.coffeelint optFile: './.coffeelintrc')
    .pipe($.coffeelint.reporter())
    .pipe($.cond map, gulp.dest dest)
    .pipe($.coffee bare: true, sourceMap: map)
    .pipe(coffeeFilter.restore())
    .pipe(gulp.dest dest)

gulp.task 'sass', ['copy static', 'rename css'], ->
  gulp.src("#{ config.client.src.styles }/main.scss")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.sass includePaths: require('node-bourbon').with config.client.build.root)
    .pipe(gulp.dest config.client.build.assets)

gulp.task 'rename css', ->
  gulp.src("#{ config.client.src.styles }/**/*.css")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.clean())
    .pipe($.rename extname: '.scss')
    .pipe(gulp.dest config.client.build.assets)

gulp.task 'templates', ->
  gulp.src("#{ config.client.src.scripts }/**/*.hamlc")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.assets)
    .pipe($.hamlc placement: 'amd')
    .pipe(gulp.dest config.client.build.assets)

gulp.task 'pages', ->
  files = [
    "#{ config.client.src.pages }/**/*.hamlc"
    "!#{ config.client.src.pages }/**/_*.hamlc"
  ]

  gulp.src(files)
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.root)
    .pipe($.hamlc target: 'html', ext: '.html', context: config)
    .pipe(gulp.dest config.client.build.root)

# ------------------------------------------------------------------------------
# Server
# ------------------------------------------------------------------------------
gulp.task 'server', ->
  nodemon = require 'nodemon'

  nodemon
    script: config.server.main
    watch: config.server.root
    ext: 'js coffee json'

  nodemon
    .on('start', -> console.log 'Server has started')
    .on('quit', -> console.log 'Server has quit')
    .on('restart', (files) -> console.log 'Server restarted due to: ', files)

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'build', (cb) ->
  sequence = [
    ['copy bower', 'scripts', 'templates', 'copy static', 'pages', 'sass']
    cb
  ]
  runSequence sequence...

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', ['ensure build dir'], (cb) ->
  lr = $.livereload config.livereload.port

  gulp.watch("#{ config.client.build.root }/**")
    .on 'change', (file) -> lr.changed file.path

  gulp.watch "#{ config.client.src.scripts }/**", ['scripts']
  gulp.watch "#{ config.client.src.styles }/**/*.scss", ['sass']
  gulp.watch "#{ config.client.src.scripts }/**/*.hamlc", ['templates']
  gulp.watch "#{ config.client.src.pages }/**/*.hamlc", ['pages']
  gulp.watch "#{ config.client.src.static }/**", ['copy static']

  cb()

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', ->
  runSequence 'clean build', 'build', ['watch', 'server']
