execute = (task, options, next) ->
  try
    unless execute.commands[task]
      throw new Error "Command '#{ task }' does not exist"

    execute.commands[task] options, next
  catch e
    log.error e

execute.commands =
  help: require './commands/help'
  init: require './commands/init'
  install: require './commands/install'
  update: require './commands/update'
  version: require './commands/version'

module.exports = execute
