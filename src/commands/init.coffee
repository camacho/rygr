{log, colors, asyncQueue} = require 'rygr-util'

module.exports = (env, done) ->
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

  configureProject = (env, next) ->
    log 'Configuring project'

    for name, loc of {npm: 'package', 'Bower': 'bower'}

      loc = path.join env.cwd, loc

      contents = require loc
      contents.name = env.projectName

      json = JSON.stringify contents, undefined, 2

      try
        fs.writeFileSync "#{ loc }.json", json
      catch e
        return next err if err

    log colors.green 'Project configured'
    next()

  success = (env, next) ->
    log colors.bold colors.green 'rygr project successfully initiated'
    next()

  runGulp = (env, next) ->
    questions = [{
      type: 'confirm'
      name: 'run'
      message: colors.green 'Compile and launch website?'
      default: true
    }]

    inquirer.prompt questions, (answers) ->
      if answers.run
        require('./gulp') env, next
      else
        return next()

  nextSteps = (env, next) ->
    cmds = ['gulp']
    cmds.unshift "cd #{ env.cwd }" if env.cwd isnt process.env.INIT_CWD
    cmds = colors.cyan cmds.join ' && '
    console.log "run `#{ cmds }` to build, watch, and start the server"

  asyncQueue [env], [
    ensureDirectory
    sanitizeProjectName
    copyTemplate
    require('./install_global')
    configureProject
    require('./install')
    success
    runGulp
    nextSteps
    (err, env, next) -> log.error err
  ], done
