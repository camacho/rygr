path = require 'path'
client = require './client'

baseDir = path.relative client.build.public, client.build.assets
vendorDir = path.relative client.build.assets, client.build.vendor

module.exports =
  catchError:
    define: true

  paths:
    jquery: "#{vendorDir}/jquery/dist/jquery"
    jade: "/jade"

  baseUrl: path.relative client.build.public, client.build.assets
