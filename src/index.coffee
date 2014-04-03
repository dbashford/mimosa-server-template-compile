"use strict"

path = require "path"
fs = require "fs"

wrench = require "wrench"
cons = require 'consolidate'
_ = require "lodash"
pretty = require("html").prettyPrint

config = require './config'

logger = null

registration = (mimosaConfig, register) ->
  logger = mimosaConfig.log

  if mimosaConfig.isBuild
    register ['postBuild'], 'beforePackage', _compileTemplates

  register ['preClean'], 'init', _clean

_compileTemplates = (mimosaConfig, options, next) ->
  st = mimosaConfig.serverTemplate
  compileFiles = __genCompileFiles st
  return next() unless compileFiles?.length > 0

  i = 0
  done = ->
    if ++i is compileFiles.length
      next()

  compileFiles.forEach (f) ->
    locals = __getLocals st, f
    logger.debug "server-template-compile compiling [[ #{f} ]]"
    cons[st.compileWith] f, locals, (err, html) ->
      if err
        logger.error "Compilation failed on file [[ #{f} ]]:\n#{err}"
        done()
      else
        unless mimosaConfig.isMinify or mimosaConfig.isOptimize
          html = pretty html
        __writeOutputFile st, f, html, done

_clean = (mimosaConfig, options, next) ->
  st = mimosaConfig.serverTemplate
  compileFiles = __genCompileFiles st
  return next() unless compileFiles?.length > 0

  i = 0
  done = ->
    if ++i is compileFiles.length
      next()

  compileFiles.forEach (f) ->
    outFileName = __genOutFileName st.outPath, st.inPath, f
    fs.exists outFileName, (exists) ->
      if exists
        fs.unlink outFileName, ->
          logger.success "Deleted compiled template [[ #{outFileName} ]]"
          done()
      else
        done()

__getLocals = (st, f) ->
  locals = if st.views?
    locs = st.locals
    for v in st.views
      if v.path is f and v.locals?
        locs = v.locals
        break
    locs
  else
    st.locals

  _.clone(locals, true)

__writeOutputFile = (st, f, html, cb) ->
  outFileName = __genOutFileName st.outPath, st.inPath, f
  dirname = path.dirname outFileName
  fs.exists dirname, (exists) ->
    unless exists
      logger.debug "server-template-compile making directory [[ #{dirname} ]]"
      wrench.mkdirSyncRecursive dirname, 0o0777

    fs.writeFile outFileName, html, "utf8", (err) ->
      if err
        logger.error "Error writing [[ #{outFileName} ]]"
      else
        logger.success "server-template-compile wrote file [[ #{outFileName} ]]"
      cb()

__genCompileFiles = (config) ->
  allFiles = wrench.readdirSyncRecursive(config.inPath).map (f) -> path.join config.inPath, f
  compileFiles = allFiles.filter (f) -> config.exclude.indexOf(f) is -1
  compileFiles = compileFiles.filter (f) -> path.extname(f) is ".#{config.extension}"

__genOutFileName = (outPath, inPath, f) ->
  outFileName = path.join(outPath, f.replace(inPath, ""))
  outFileName.replace(path.extname(outFileName), ".html")

module.exports =
  registration: registration
  defaults:     config.defaults
  placeholder:  config.placeholder
  validate:     config.validate