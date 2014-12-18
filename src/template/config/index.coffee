module.exports = require('rygr-util').config.initialize(
  "#{__dirname}/*.{json,coffee}",
  "!#{__filename}"
)
