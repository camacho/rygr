{colors, log} = require 'rygr-util'

module.exports = (env, done) ->
  cliPackage = require '../../package'
  log "Version #{colors.cyan cliPackage.version}"

  done?()
