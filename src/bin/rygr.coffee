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
{colors, log, file} = require 'rygr-util'
Liftoff = require 'liftoff'
argv = require('minimist') process.argv.slice 2

# ------------------------------------------------------------------------------
# Read in args
# ------------------------------------------------------------------------------
versionFlag = argv.v or argv.version
helpFlag = argv.h or argv.help
cmds = argv._

# ------------------------------------------------------------------------------
# Register commands
# ------------------------------------------------------------------------------
commands = require '../commands/main'

# ------------------------------------------------------------------------------
# Run logic
# ------------------------------------------------------------------------------
run = (env) ->
  execute = runCommand.bind runCommand, env

  if versionFlag
    execute 'version'
    process.exit 0

  if helpFlag
    execute 'help'
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
    throw new Error "Command '#{ task }' does not exist" unless commands[task]
    commands[task] env, handleError
  catch e
    handleError e

# ------------------------------------------------------------------------------
# Error Handling
# ------------------------------------------------------------------------------
handleError = (err, env, cb) ->
  failed = true

  err =
    if not err.err
      err.message
    else if typeof err.err is 'string'
      new Error(err.err).stack
    else if typeof e.err.showStack is 'boolean'
      err.err.toString()
    else
      err.err.stack

  log colors.red err

# ------------------------------------------------------------------------------
# Setup CLI
# ------------------------------------------------------------------------------
new Liftoff(name: 'rygr').launch {}, run
