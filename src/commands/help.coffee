module.exports = (env, handleError) ->
  {colors} = require 'rygr-util'

  console.log "\n  usage: #{ colors.bold 'rygr <command>' }\n"
  console.log "  where #{ colors.bold '<command>' } is one of:"
  console.log '    help, init, install, update, version\n'
