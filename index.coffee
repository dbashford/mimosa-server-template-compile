"use strict"

path = require "path"
fs = require "fs"

wrench = require "wrench"
logger = require "logmimosa"
cons = require 'consolidate'
_ = require "lodash"

config = require './config'

registration = (mimosaConfig, register) ->
  if mimosaConfig.isBuild
    register ['postBuild'], 'beforePackage', _compileTemplates

_compileTemplates = (mimosaConfig, options, next) ->

  st = mimosaConfig.serverTemplate

  allFiles = wrench.readdirSyncRecursive(st.inPath).map (f) -> path.join st.inPath, f
  compileFiles = allFiles.filter (f) -> st.exclude.indexOf(f) is -1
  compileFiles = compileFiles.filter (f) -> path.extname(f) is ".#{st.extension}"

  logger.debug "server-template-compile will be compiling the following templates: #{compileFiles.join('\n')}"

  return next() unless compileFiles?.length > 0

  i = 0
  done = ->
    next() if ++i is compileFiles.length

  compileFiles.forEach (f) ->
    locals = __getLocals st, f
    logger.debug "server-template-compile compiling [[ #{f} ]]"
    cons[st.compileWith] f, locals, (err, html) ->
      if err
        logger.error "Compilation failed on file [[ #{f} ]]:\n#{err}"
        done()
      else
        __writeOutputFile st, f, html, done

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
  outFileName = path.join(st.outPath, f.replace(st.inPath, ""))

  dirname = path.dirname outFileName
  fs.exists dirname, (exists) ->
    unless exists
      logger.debug "server-template-compile making directory [[ #{dirname} ]]"
      wrench.mkdirSyncRecursive dirname, 0o0777

    fs.writeFileSync outFileName, html, "utf8", (err) ->
      if err
        logger.error "Error writing [[ #{outFileName} ]]"
      else
        logger.debug "server-template-compile wrote file [[ #{outFileName} ]]"

      cb()

module.exports =
  registration: registration
  defaults:     config.defaults
  placeholder:  config.placeholder
  validate:     config.validate