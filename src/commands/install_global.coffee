globalDependencies =
  'coffee-script': '^1.7.1'
  gulp: '^3.8.7'
  bower: '^1.3.9'

module.exports = (options, done) ->
  {log, colors, asyncQueue} = require 'rygr-util'
  _ = require 'underscore'
  semver = require 'semver'
  inquirer = require 'inquirer'
  npm = require 'npm'

  installGlobalNpms = (options, next) ->
    log 'Checking global dependencies'

    npm.load global: true, (err) ->
      return next err if err

      npm.commands.ls [], true, (err, packages) ->
        return next err if err

        needed = []

        for dep, requiredVers of globalDependencies
          installedVers = packages.dependencies[dep]?.version

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

      npm.commands.install answers.dependencies, (err, data) ->
        return next err if err
        log colors.green 'Global dependencies installed'
        next()

  asyncQueue [options], [
    installGlobalNpms
    (err, options, next) -> log.error err
  ], done
