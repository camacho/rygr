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

{config} = require 'rygr-util'
config.initialize 'config/*.json'

# ------------------------------------------------------------------------------
# Custom vars and methods
# ------------------------------------------------------------------------------
alertError = $.notify.onError (error) ->
  message = error?.message or error?.toString() or 'Something went wrong'
  "Error: #{ message }"

# ------------------------------------------------------------------------------
# Directory management
# ------------------------------------------------------------------------------
gulp.task 'clean', (cb) ->
  dirs = [config.client.build.root]
  glob = []

  for dir in dirs
    fs.mkdirSync dir unless fs.existsSync dir
    glob.push "#{ dir }/**", "!#{ dir }"

  require('del') glob, cb
  
# ------------------------------------------------------------------------------
# Copy static assets
# ------------------------------------------------------------------------------
gulp.task 'public', ->
  gulp.src("#{ config.client.src.public }/**")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.root)
    .pipe gulp.dest config.client.build.root

gulp.task 'bower', ->
  gulp.src(require('main-bower-files')(), base: './bower_components')
    .pipe($.filter '!**/*.scss')
    .pipe($.plumber errorHandler: alertError)
    .pipe gulp.dest config.client.build.assets

gulp.task 'rename bower css', ->
  gulp.src("bower_components/**/*.css")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.rename prefix: '_', extname: '.scss')
    .pipe(gulp.dest 'bower_components')

# ------------------------------------------------------------------------------
# Compile assets
# ------------------------------------------------------------------------------
gulp.task 'scripts', ->
  coffeeFilter = $.filter '**/*.coffee'
  useSourceMaps = config.client.scripts.sourceMap
  relativeMapsDir = path.relative(
    config.client.build.assets, 
    config.client.build.maps
  )
  srcUrlRoot = "/#{
    path.relative(
      config.client.build.root, 
      config.client.build.src
    )
  }"

  gulp.src("#{ config.client.src.scripts }/**/*.{js,coffee}")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.assets)
    .pipe($.preprocess context: ENV: ENV)
    .pipe(coffeeFilter)
    .pipe($.coffeelint optFile: './.coffeelintrc')
    .pipe($.coffeelint.reporter())
    .pipe($.if useSourceMaps, $.sourcemaps.init())
    .pipe($.if useSourceMaps, gulp.dest config.client.build.src)
    .pipe($.coffee bare: true)
    .pipe($.if useSourceMaps, $.sourcemaps.write(
      relativeMapsDir, 
      includeContent: false, 
      sourceRoot: srcUrlRoot
    ))
    .pipe(coffeeFilter.restore())
    .pipe(gulp.dest config.client.build.assets)

gulp.task 'templates', ->
  gulp.src("#{ config.client.src.scripts }/**/*.jade")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.preprocess context: ENV: ENV)
    .pipe($.jade client: true)
    .pipe($.wrapAmd deps: ['jade'], params: ['jade'])
    .pipe(gulp.dest config.client.build.assets)

gulp.task 'sass', ['public', 'bower', 'images'], ->
  gulp.src("#{ config.client.src.styles }/main.scss")
    .pipe($.sass
      onError: alertError
      includePaths: require('node-bourbon').with(
        config.client.build.root,
        'bower_components'
      )
      imagePath: config.client.sass.imagePath
      sourceMap: config.client.sass.sourceMap
    )
    .pipe(gulp.dest config.client.build.assets)

gulp.task 'images', ->
  gulp.src("#{ config.client.src.images }/**")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.assets)
    .pipe($.imagemin())
    .pipe(gulp.dest config.client.build.assets)

gulp.task 'html', ->
  jadeFilter = $.filter '**/*.jade'

  gulp.src("#{ config.client.src.html }/**")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.root)
    .pipe($.preprocess context: ENV: ENV)
    .pipe(jadeFilter)
    .pipe($.jade locals: config)
    .pipe(jadeFilter.restore())
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

  if ENV isnt 'production'
    nodemon
      .on('start', -> console.log 'Server has started')
      .on('quit', -> console.log 'Server has quit')
      .on('restart', (files) -> console.log 'Server restarted due to: ', files)

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'build', (cb) ->
  sequence = [
    'clean'
    ['bower', 'scripts', 'templates', 'images', 'public', 'html', 'sass']
    cb
  ]
  runSequence sequence...

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'test', ['build'], (cb) ->
  # TODO - write tests
  cb()

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', (cb) ->
  return cb() unless ENV is 'development'

  lr = $.livereload config.livereload.port
  gulp.watch("#{ config.client.build.root }/**")
    .on 'change', (file) -> lr.changed file.path

  gulp.watch "#{ config.client.src.scripts }/**/*.{js,coffee}", ['scripts']
  gulp.watch "#{ config.client.src.scripts }/**/*.jade", ['templates']
  gulp.watch "#{ config.client.src.styles }/**/*.scss", ['sass']
  gulp.watch "#{ config.client.src.html }/**/*.{jade, html}", ['html']
  gulp.watch "#{ config.client.src.images }/**", ['images']
  gulp.watch "#{ config.client.src.public }/**", ['public']

  cb()

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', ->
  runSequence 'build', ['watch', 'server']
