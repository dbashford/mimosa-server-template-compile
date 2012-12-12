"use strict"

config = require './config'

registration = (mimosaConfig, register) ->
  if mimosaConfig.isBuild
    register ['buildDone'],      'beforePackage', _compileTemplates

_compileTemplates = (mimosaConfig, options, next) ->

  next()

module.exports =
  registration: registration
  defaults:     config.defaults
  placeholder:  config.placeholder
  validate:     config.validate