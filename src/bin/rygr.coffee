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
path = require 'path'
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
    if cmds[0] is 'init' and cmds.length is 2
      [cmd, dir] = cmds
      env.cwd = path.resolve process.cwd(), dir
      execute cmd
    else
      execute cmds.join(' ')

runCommand = (env, task) ->
  try
    throw new Error "Command '#{ task }' does not exist" unless commands[task]
    commands[task] env
  catch e
    log.error e

# ------------------------------------------------------------------------------
# Setup CLI
# ------------------------------------------------------------------------------
new Liftoff(name: 'rygr').launch {}, run
