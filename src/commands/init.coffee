{log, colors, asyncQueue} = require 'rygr-util'

module.exports = (env, handleError) ->
  log colors.bold colors.green 'Initializing new rygr project'

  path = require 'path'
  fs = require 'fs-extra'
  semver = require 'semver'
  inquirer = require 'inquirer'
  _ = require 'underscore'

  projectName = path.basename process.env.INIT_CWD
  projectPackage = null

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

  copyTemplate = (env, next) ->
    log 'Copying files'

    templatePath = path.join __dirname, '../', 'template'
    fs.copy templatePath, env.cwd, (err) ->
      return next err if err
      log colors.green 'Files copied'
      projectPackage = require path.join env.cwd, 'package'
      next()

  installGlobalNpms = (env, next) ->
    log 'Checking global dependencies'

    npm = require 'npm'

    npm.load global: true, (err) ->
      return next err if err

      npm.commands.ls [], true, (err, packages) ->
        return next err if err

        needed = []

        for dep in ['coffee-script', 'gulp']
          requiredVers =
            projectPackage.dependencies[dep] or
            projectPackage.devDependencies[dep]

          installedVers = packages.dependencies[dep]?.version

          continue if installedVers and not requiredVers

          install = dep
          install += "@#{ requiredVers.replace /(\^|\~)/g, ''}" if requiredVers

          unless semver.satisfies installedVers, requiredVers
            needed.push
              required: requiredVers
              current: installedVers
              npm: dep
              install: install

        unless needed.length
          log colors.green 'All global dependencies are installed'
          return next()

        promptNpmInstalls needed, next

  promptNpmInstalls = (needed, next) ->
    console.log 'Some global npm dependencies are missing or out of date:'

    installs = []
    upgrades = []
    choices = []

    for need in needed
      choice = name: need.install, checked: true
      if need.current then upgrades.push choice else installs.push choice

    if installs.length
      choices.push new inquirer.Separator 'Installs:'
      choices = choices.concat installs

    if upgrades.length
      choices.push new inquirer.Separator 'Upgrades:'
      choices = choices.concat upgrades

    inquirer.prompt [{
      type: 'checkbox'
      name: 'dependencies'
      message: 'Select which global npm dependencies to install or upgrade'
      choices: choices
    }], (answers) ->
      chosen = answers.dependencies

      # Are all required installs chosen?
      required = installs.map (install) -> install.name
      if (diff = _.difference required, chosen).length
        diff = diff.map (item) -> "'#{ item.split('@')[0] }'"
        return next new Error "#{ diff.join ', ' } must be installed to proceed"

      # Are all upgrades chosen?
      optional = upgrades.map (upgrade) -> upgrade.name
      if (diff = _.difference optional, chosen).length
        diff = diff.map (item) -> "'#{ item.split('@')[0] }'"
        log colors.yellow "#{ diff.join ', ' } should be upgraded"

      return next() unless chosen.length

      npm = require 'npm'

      npm.commands.install answers.dependencies, (err, data) ->
        return next err if err
        log colors.green 'Global dependencies installed'
        next()

  initializeNpm = (env, next) ->
    log 'Configuring NPM'

    projectPackage.name = projectName

    loc = path.join env.cwd, 'package'
    value = JSON.stringify projectPackage, undefined, 2

    fs.writeFile "#{ loc }.json", value, (err) ->
      return next err if err
      log colors.green 'NPM configured'
      next()

  initializeBower = (env, next) ->
    log 'Configuring Bower'

    loc = path.join env.cwd, 'bower'
    (conf = require loc).name = projectName

    fs.writeFile "#{ loc }.json", JSON.stringify(conf, undefined, 2), (err) ->
      return next err if err
      log colors.green 'Bower configured'
      next()

  installLocalDependenies = (env, next) ->
    require('./install') env, handleError, (err) ->
      return if err
      next()

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
      if answers.run
        shell = require 'shelljs'

        shell.exec 'gulp build', (code) ->
          return next new Error 'Gulp failed to run' if code isnt 0
          shell.exec 'gulp server watch', (code) ->
            next new Error 'Gulp failed to start the server' if code isnt 0

          # Hack until I build a way to listen to server start on child process
          setTimeout (-> require('open') 'http://localhost:8888'), 2000
          next()

      else
        console.log colors.green 'Run `gulp` and
        then visit http://localhost:8888'

        next()

  asyncQueue [env], [
    ensureDirectory
    copyTemplate
    installGlobalNpms
    initializeNpm
    initializeBower
    installLocalDependenies
    success
    gulp
    handleError
  ]
