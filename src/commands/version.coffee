{colors, log} = require 'rygr-util'

module.exports = ->
  cliPackage = require '../../package'
  log "Version #{colors.cyan cliPackage.version}"
