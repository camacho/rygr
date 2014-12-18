path = require 'path'

root = 'client'
srcRoot = "#{root}/src"

buildRoot = "#{root}/build"
buildPublic = "#{buildRoot}/public"
buildAssetsDir = "#{buildPublic}/assets"

module.exports =
  root: root
  src:
    root: srcRoot,
    html: "#{srcRoot}/html"
    styles: "#{srcRoot}/stylesheets"
    public: "#{srcRoot}/public"
    scripts: "#{srcRoot}/scripts"
    images: "#{srcRoot}/images"
  sass:
    sourceMap: false
  scripts:
    sourceMap: false
  build:
    root: buildRoot
    tmp: "#{root}/.tmp"
    public: buildPublic
    manifest: "#{buildPublic}/asset_manifest.json"
    assets: buildAssetsDir
    maps: "#{buildAssetsDir}/_maps"
    src: "#{buildAssetsDir}/_src"
    vendor: "#{buildAssetsDir}/vendor"
  environments:
    development:
      sass:
        sourceMap: true
      scripts:
        sourceMap: true
