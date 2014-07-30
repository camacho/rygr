`#!/usr/bin/env node
'use strict'`

# ------------------------------------------------------------------------------
# Setup
# ------------------------------------------------------------------------------
process.env.INIT_CWD = process.cwd()
failed = false
process.once 'exit', (code) -> process.exit 1 if code is 0 and failed

# ------------------------------------------------------------------------------
# Load in modules
# ------------------------------------------------------------------------------
{colors, log} = require 'bedrock-utils'
prettyTime = require 'pretty-hrtime'
Liftoff = require 'liftoff'
interpret = require 'interpret'
argv = require('minimist') process.argv.slice 2
fs = require 'fs-extra'
npm = require 'npm'
bower = require 'bower'
inquirer =  require 'inquirer'

# ------------------------------------------------------------------------------
# Setup CLI
# ------------------------------------------------------------------------------
cli = new Liftoff
  name: 'bedrock'
  extensions: interpret.jsVariants

cli.on 'require', (name) ->
  butils.log 'Requiring external module', colors.magenta name

cli.on 'requireFail', (name) ->
  butils.log colors.red('Failed to load external module'), colors.magenta name

# ------------------------------------------------------------------------------
# Read in args
# ------------------------------------------------------------------------------
cliPackage = require '../../package'
versionFlag = argv.v or argv.version
cmds = argv._

# ------------------------------------------------------------------------------
# Register commands
# ------------------------------------------------------------------------------
commands =
  version: (env) ->
    log 'CLI version', cliPackage.version
    log 'Local version', env.modulePackage.version if env.modulePackage?.version

  init: (env) ->
    templatePath = require('path').join __dirname, '../', 'template'
    fs.copySync templatePath, env.cwd
    globalPackages = ['coffee-script', 'bower', 'gulp']

    log colors.magenta 'Installing global NPMs'
    npm.load global: true, ->
      npm.commands.install globalPackages, (err, data) ->
        if err then logError err
        npm.load {}, ->
          log colors.magenta 'Initializing NPM'
          npm.commands.init [], (err) ->
            if err then logError
            log colors.magenta 'Initializing Bower'
            bower.commands
              .init({interactive: true})
              .on 'prompt', (prompts, callback) ->
                inquirer.prompt prompts, callback
              .on 'error', logError
              .on 'end', ->
                log colors.magenta 'Installing core Bower packages'
                bower.commands.install(
                  ['jquery', 'requirejs'], {save: true}, {interactive: true}
                )
                  .on 'prompt', (prompts, callback) ->
                    inquirer.prompt prompts, callback
                  .on 'error', logError
                  .on 'end', commands.install.bind commands, env

  install: (env) ->
    log colors.magenta 'Installing local NPMs'
    npm.load {}, ->
      npm.commands.install [], (err, data) ->
        if err then logError err
        log colors.magenta 'Installing Bower packages'
        bower.commands.install(undefined, {allowRoot: true}, {interactive: true})
        .on 'prompt', (prompts, callback) ->
          inquirer.prompt prompts, callback
        .on 'error', logError

  update: (env) ->
    commands.update env

# ------------------------------------------------------------------------------
# Run logic
# ------------------------------------------------------------------------------
run = (env) ->
  execute = runCommand.bind runCommand, env

  if versionFlag
    execute 'version'
    process.exit 0

  unless cmds.length
    availCmds = Object.keys(commands).map((key) -> colors.magenta key).join ', '
    log colors.red 'No command specified'
    log "Avaiable commands are [#{ availCmds }]"
    process.exit 5

  process.nextTick ->
    execute cmd for cmd in cmds

runCommand = (env, task) ->
  try
    commands[task] env
  catch e
    logError e, task

# ------------------------------------------------------------------------------
# Error Handling
# ------------------------------------------------------------------------------
formatError = (e) ->
  if not e.err
    e.message
  else if typeof e.err is 'string'
    new Error(e.err).stack
  else if typeof e.err.showStack is 'boolean'
    e.err.toString()
  else
    e.err.stack

logError = (e, task) ->
  msg = colors.red formatError e
  log "\'#{colors.cyan(task)}\' #{colors.red 'errored'}" if task
  log msg

# ------------------------------------------------------------------------------
# Launch
# ------------------------------------------------------------------------------
cli.launch {
  cwd: argv.cwd,
  configPath: argv.gulpfile,
  require: argv.require
}, run
