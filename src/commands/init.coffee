{log, colors, asyncQueue} = require 'rygr-util'

module.exports = (env, handleError) ->
  log colors.bold colors.green 'Initializing new rygr project'

  path = require 'path'
  fs = require 'fs-extra'
  inquirer = require 'inquirer'
  _ = require 'underscore'
  spawn = require('child_process').spawn

  ensureDirectory = (env, next) ->
    log 'Configuring directory'

    return next() if env is process.cwd()

    fs.exists env.cwd, (exists) ->
      return next new Error "Directory '#{ env.cwd }' already exists" if exists

      fs.mkdir env.cwd, (err) ->
        return next err if err

        process.chdir env.cwd

        log colors.green 'Directory configured'
        next()

  sanitizeProjectName = (env, next) ->
    log 'Sanitizing project name'

    env.projectName = path.basename(env.cwd)
      .replace(/[\/@\+%:]/g, '')
      .replace(/[\s]/g, '-')

    log colors.green 'Project name sanitized'
    next()

  copyTemplate = (env, next) ->
    log 'Copying files'

    templatePath = path.join __dirname, '../', 'template'
    fs.copy templatePath, env.cwd, (err) ->
      return next err if err
      log colors.green 'Files copied'
      next()

  installGlobalNpms = (env, next) ->
    require('./install_global_npms') env, handleError, next

  initializeNpm = (env, next) ->
    log 'Configuring NPM'

    loc = path.join env.cwd, 'package'

    projectPackage = require loc
    projectPackage.name = env.projectName

    json = JSON.stringify projectPackage, undefined, 2

    fs.writeFile "#{ loc }.json", json, (err) ->
      return next err if err
      log colors.green 'NPM configured'
      next()

  initializeBower = (env, next) ->
    log 'Configuring Bower'

    loc = path.join env.cwd, 'bower'
    (conf = require loc).name = env.projectName

    fs.writeFile "#{ loc }.json", JSON.stringify(conf, undefined, 2), (err) ->
      return next err if err
      log colors.green 'Bower configured'
      next()

  installLocalDependenies = (env, next) ->
    require('./install') env, handleError, next

  success = (env, next) ->
    log colors.bold colors.green 'rygr project successfully initiated'
    next()

  gulp = (env, next) ->
    questions = [{
      type: 'confirm'
      name: 'run'
      message: colors.green 'Compile and launch website?'
      default: true
    }]

    inquirer.prompt questions, (answers) ->
      unless answers.run
        console.log colors.green 'Run `gulp` and
        then visit http://localhost:8888'

        return next()

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
          next()

      gulp = spawn 'gulp'
      gulp.stdout.pipe process.stdout, end: false
      gulp.stderr.pipe process.stderr
      gulp.once 'close', handleClose
      gulp.stdout.on 'data', listenForServerStart

  asyncQueue [env], [
    ensureDirectory
    sanitizeProjectName
    copyTemplate
    installGlobalNpms
    initializeNpm
    initializeBower
    installLocalDependenies
    success
    gulp
    handleError
  ]
