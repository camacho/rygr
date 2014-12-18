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
config = require './config/index'

# ------------------------------------------------------------------------------
# Custom vars and methods
# ------------------------------------------------------------------------------
alertError = $.notify.onError (error) ->
  message = error?.message or error?.toString() or 'Something went wrong'
  "Error: #{message}"

cleanDirSync = (dir) ->
  require('del').sync "#{dir}/**"

# ------------------------------------------------------------------------------
# Directory management
# ------------------------------------------------------------------------------
gulp.task 'clean', (cb) ->
  fs = require 'fs'
  dirs = [config.client.build.root]
  glob = []

  for dir in dirs
    fs.mkdirSync dir unless fs.existsSync dir
    glob.push "#{dir}/**", "!#{dir}"

  require('del') glob, cb

# ------------------------------------------------------------------------------
# Copy static assets
# ------------------------------------------------------------------------------
gulp.task 'public', ->
  gulp.src("#{config.client.src.public}/**/*.*")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.public)
    .pipe(gulp.dest config.client.build.public)
    .pipe($.livereload())

gulp.task 'bower', ->
  gulp.src(require('main-bower-files')(), base: './bower_components')
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.vendor)
    .pipe($.filter '**/*.!(scss)')
    .pipe(gulp.dest config.client.build.vendor)
    .pipe($.livereload())

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
    path.relative config.client.build.public, config.client.build.src
  }"

  gulp.src("#{config.client.src.scripts}/**/*.{js,coffee}")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.assets, extension: '.js')
    .pipe($.preprocess context: ENV: ENV)
    .pipe(coffeeFilter)
    .pipe($.coffeelint optFile: './.coffeelintrc')
    .pipe($.coffeelint.reporter())
    .pipe($.if useSourceMaps, $.sourcemaps.init())
    .pipe($.if useSourceMaps, gulp.dest config.client.build.src)
    .pipe($.coffee bare: true)
    .pipe($.if(
      useSourceMaps,
      $.sourcemaps.write(
        relativeMapsDir,
        includeContent: false, sourceRoot: srcUrlRoot
      )
    ))
    .pipe(coffeeFilter.restore())
    .pipe(gulp.dest config.client.build.assets)
    .pipe($.livereload())

gulp.task 'templates', ->
  gulp.src("#{config.client.src.scripts}/**/*.jade")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.assets, extension: '.js')
    .pipe($.preprocess context: ENV: ENV)
    .pipe($.jade client: true)
    .pipe($.wrapAmd deps: ['jade'], params: ['jade'])
    .pipe(gulp.dest config.client.build.assets)
    .pipe($.livereload())

gulp.task 'sass', ['public', 'bower', 'images'], ->
  gulp.src("#{config.client.src.styles}/main.scss")
    .pipe($.sass
      onError: alertError
      includePaths: require('node-bourbon').with(
        config.client.build.public,
        './bower_components'
      )
      imagePath: "/#{path.basename config.client.build.assets}"
      sourceMap: config.client.sass.sourceMap
    )
    .pipe(gulp.dest config.client.build.assets)
    .pipe($.livereload())

gulp.task 'images', ->
  if ENV is 'production'
    imageMinification = $.imagemin
      optimizationLevel: 7
      progressive: true
      interlaced: true

  gulp.src("#{config.client.src.images}/**/*.*")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.assets)
    .pipe($.if (ENV is 'production'), imageMinification or ->)
    .pipe(gulp.dest config.client.build.assets)
    .pipe($.livereload())

gulp.task 'html', ->
  jadeFilter = $.filter '**/*.jade'

  gulp.src("#{config.client.src.html}/**/*.*")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.public, extension: '.html')
    .pipe($.preprocess context: ENV: ENV)
    .pipe(jadeFilter)
    .pipe($.jade locals: config)
    .pipe(jadeFilter.restore())
    .pipe(gulp.dest config.client.build.public)
    .pipe($.livereload())

# ------------------------------------------------------------------------------
# Optimize assets
# ------------------------------------------------------------------------------
gulp.task 'rjs', (cb) ->
  cleanDirSync config.client.build.tmp

  rjsConfig = _.extend {}, config.requirejs, {
    dir: config.client.build.tmp
    appDir: config.client.build.assets
    baseUrl: './'
}

  require('requirejs').optimize(
    rjsConfig,
    ((buildResponse) ->
      cleanDirSync config.client.build.assets
      fs.renameSync config.client.build.tmp, config.client.build.assets
      cb()
    ), ((error) ->
      try cleanDirSync config.client.build.tmp
      cb error
    )
  )

  undefined

gulp.task 'gzip', ->
  gulp.src([
    "#{config.client.build.public}/**"
    "!#{config.client.build.manifest}"
  ])
    .pipe($.gzip())
    .pipe(gulp.dest config.client.build.public)

gulp.task 'productionize', (cb) ->
  runSequence 'rjs', 'gzip', cb

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'build', (cb) ->
  sequence = [
    'clean'
    ['bower', 'scripts', 'templates', 'images', 'public', 'html', 'sass']
  ]

  sequence.push 'productionize' if ENV is 'production'
  sequence.push cb

  runSequence sequence...

# ------------------------------------------------------------------------------
# Server
# ------------------------------------------------------------------------------
gulp.task 'server', ->
  nodemon = require 'nodemon'

  nodemon
    script: config.server.main
    watch: config.server.root
    ext: 'js coffee json jade'

  if ENV isnt 'production'
    nodemon
      .on('start', -> console.log 'Server has started')
      .on('quit', -> console.log 'Server has quit')
      .on('restart', (files) -> console.log 'Server restarted due to: ', files)

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
gulp.task 'test', ['build'], (cb) ->
  # TODO - write tests
  cb()

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', (cb) ->
  return cb() unless ENV is 'development'

  $.livereload.listen
    port: config.livereload.port
    basePath: config.client.build.public

  gulp.watch "#{config.client.src.scripts}/**/*.{js,coffee}", ['scripts']
  gulp.watch "#{config.client.src.scripts}/**/*.jade", ['templates']
  gulp.watch "#{config.client.src.styles}/**/*.scss", ['sass']
  gulp.watch "#{config.client.src.html}/**/*.{jade, html}", ['html']
  gulp.watch "#{config.client.src.images}/**", ['images']
  gulp.watch "#{config.client.src.public}/**", ['public']

  cb()

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', ->
  runSequence 'build', ['watch', 'server']
