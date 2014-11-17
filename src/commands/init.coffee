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

    done = ->
      process.chdir options.dir
      log colors.green 'Directory configured'
      next()

    fs.exists options.dir, (exists) ->
      if exists
        files = fs.readdir options.dir, (err, files) ->
          return next err if err

          if files.length
            log "#{ colors.bgYellow colors.black 'WARN' }
            '#{ options.dir }' already exists and contains files"

            questions = [{
              type: 'confirm'
              name: 'continue'
              message: 'Initialize rygr project anyway?'
              default: false
            }]

            inquirer.prompt questions, (answers) ->
              if answers.continue
                log colors.yellow 'Continuing with populated directory.'
                log colors.yellow 'This might override files.'
                done()
              else
                log colors.red 'Rygr init aborted!'
          else
            done()
      else
        fs.mkdir options.dir, (err) ->
          return next err if err
          done()

  sanitizeProjectName = (options, next) ->
    log 'Sanitizing project name'

    options.projectName = path.basename(options.dir)
      .replace(/[\/@\+%:]/g, '')
      .replace(/[\s]/g, '-')

    log colors.green 'Project name sanitized'
    next()

  copyTemplate = (options, next) ->
    log 'Copying files'

    templatePath = path.join __dirname, '../', 'template'
    fs.copy templatePath, options.dir, (err) ->
      return next err if err
      log colors.green 'Files copied'
      next()

  configureProject = (options, next) ->
    log 'Configuring project'

    for name, loc of {npm: 'package', 'Bower': 'bower'}

      loc = path.join options.dir, loc

      contents = require loc
      contents.name = options.projectName

      json = JSON.stringify contents, undefined, 2

      try
        fs.writeFileSync "#{ loc }.json", json
      catch e
        return next err if err

    readme = path.join  options.dir, 'README.md'

    require('preprocess').preprocessFileSync(
      readme,
      readme,
      PROJECT_NAME: options.projectName
    )

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

    if options.dir isnt process.env.INIT_CWD
      cmds.unshift "cd #{ options.dir }"

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
