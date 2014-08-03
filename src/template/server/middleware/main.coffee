{config, file} = require 'rygr-util'
path = require 'path'
_ = require 'underscore'
express = require 'express'

module.exports = (app) ->
  utilities = [
    require('./assets') app
    require('./client') app
    require('./missing') app
    require('./error') app
  ]

  useUtility = (utility) ->
    return unless utility

    if _.isArray utility
      useUtility util for util in utility
    else if utility.dir? and utility.method?
      app.use utility.dir, utility.method
    else
      app.use utility

  useUtility utilities
