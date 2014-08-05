commands =
    help: require './help'
    init: require './init'
    install: require './install'
    update: require './update'
    version: require './version'

module.exports = (task, options, next) ->
  try
    throw new Error "Command '#{ task }' does not exist" unless commands[task]
    commands[task] options, next
  catch e
    log.error e
