{colors, log} = require 'rygr-util'

module.exports = (options, done) ->
  cliPackage = require '../../package'
  log "Version #{colors.cyan cliPackage.version}"

  done?()
