{log, colors, asyncQueue} = require 'rygr-util'

module.exports = (options, done) ->
  log colors.bold colors.green 'Initializing new rygr project'

  path = require 'path'
  fs = require 'fs-extra'
  inquirer = require 'inquirer'
  _ = require 'underscore'
  spawn = require('child_process').spawn

  ensureDirectory = (options, next) ->
    log 'Configuring directory'

    return next() if options is process.cwd()

    fs.exists options.cwd, (exists) ->
      if exists
        return next new Error "Directory '#{ options.cwd }' already exists"

      fs.mkdir options.cwd, (err) ->
        return next err if err

        process.chdir options.cwd

        log colors.green 'Directory configured'
        next()

  sanitizeProjectName = (options, next) ->
    log 'Sanitizing project name'

    options.projectName = path.basename(options.cwd)
      .replace(/[\/@\+%:]/g, '')
      .replace(/[\s]/g, '-')

    log colors.green 'Project name sanitized'
    next()

  copyTemplate = (options, next) ->
    log 'Copying files'

    templatePath = path.join __dirname, '../', 'template'
    fs.copy templatePath, options.cwd, (err) ->
      return next err if err
      log colors.green 'Files copied'
      next()

  configureProject = (options, next) ->
    log 'Configuring project'

    for name, loc of {npm: 'package', 'Bower': 'bower'}

      loc = path.join options.cwd, loc

      contents = require loc
      contents.name = options.projectName

      json = JSON.stringify contents, undefined, 2

      try
        fs.writeFileSync "#{ loc }.json", json
      catch e
        return next err if err

    log colors.green 'Project configured'
    next()

  success = (options, next) ->
    log colors.bold colors.green 'rygr project successfully initiated'
    next()

  runGulp = (options, next) ->
    questions = [{
      type: 'confirm'
      name: 'run'
      message: colors.green 'Compile and launch website?'
      default: true
    }]

    inquirer.prompt questions, (answers) ->
      if answers.run
        require('./gulp') options, next
      else
        return next()

  nextSteps = (options, next) ->
    cmds = ['gulp']

    if options.cwd isnt process.env.INIT_CWD
      cmds.unshift "cd #{ options.cwd }"

    cmds = colors.cyan cmds.join ' && '
    console.log "run `#{ cmds }` to build, watch, and start the server"

  asyncQueue [options], [
    ensureDirectory
    sanitizeProjectName
    copyTemplate
    require('./install_global')
    configureProject
    require('./install')
    success
    runGulp
    nextSteps
    (err, options, next) -> log.error err
  ], done
