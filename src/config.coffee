"use strict"

fs = require "fs"
path = require "path"

_ = require "lodash"

exports.defaults = ->
  serverTemplate:
    exclude: ["layout.jade"]
    locals:
      title: "Mimosa"
      reload: false

exports.placeholder = ->
  """
  \t

    ###
    # This is not the full set of serverTemplate defaults as many defaults are assumed from other
    # config settings in your application. To see a complete breakdown of all the serverTemplate
    # config options (there are many), visit https://github.com/dbashford/mimosa-server-template-compile
    ###
    # serverTemplate:
      # exclude: ["layout.jade"]        # files to exclude from compilation
      # locals:                         # a list of properties to pass into all the templates when
                                      # they are compiled, the following defaults match properties
                                      # that are used in the default 'mimosa new' projects
        # title: "Mimosa"               # title of the page
        # reload: false                 # flag for whether or not to include live reload, which does
                                      # not make sense for compiled templates

  """

  ###

  ###

exports.validate = (config, validators) ->
  errors = []
  if validators.ifExistsIsObject(errors, "serverTemplate config", config.serverTemplate)
    if config.serverTemplate.compileWith?
      if typeof config.serverTemplate.compileWith is "string"
        if ['jade','hogan.js','handlebars','ejs'].indexOf(config.serverTemplate.compileWith) is -1
          errors.push "serverTemplate.compileWith must be one of: 'jade', 'hogan.js', 'handlebars', 'ejs'"
      else
        errors.push "serverTemplate.compileWith must be a string"
    else
      config.serverTemplate.compileWith = if config.server.views.compileWith?
        config.server.views.compileWith
      else
        "jade"


    if config.serverTemplate.extension?
      unless typeof config.serverTemplate.extension is "string"
        errors.push "serverTemplate.extension must be a string"
    else
      config.serverTemplate.extension = if config.server.views.extension?
        config.server.views.extension
      else
        "jade"


    if config.serverTemplate.inPath?
      unless typeof config.serverTemplate.inPath is "string"
        errors.push "serverTemplate.inPath must be a string"
    else
      config.serverTemplate.inPath = if config.server.views.path?
        config.server.views.path
      else
        "views"
    if errors.length is 0
      config.serverTemplate.inPath = validators.determinePath config.serverTemplate.inPath, config.root
      unless fs.existsSync config.serverTemplate.inPath
        errors.push "serverTemplate.inPath must exist, was resolved to [[ #{config.serverTemplate.inPath} ]]"


    if config.serverTemplate.outPath?
      unless typeof config.serverTemplate.outPath is "string"
        errors.push "serverTemplate.outPath must be a string"
    else
      config.serverTemplate.outPath = config.watch.compiledDir
    if errors.length is 0
      config.serverTemplate.outPath = validators.determinePath config.serverTemplate.outPath, config.root
      unless fs.existsSync config.serverTemplate.outPath
        errors.push "serverTemplate.outPath must exist, was resolved to [[ #{config.serverTemplate.outPath} ]]"


    if validators.ifExistsIsArray(errors, "serverTemplate.exclude", config.serverTemplate.exclude)
      newExcludes = []
      for p in config.serverTemplate.exclude
        if errors.length is 0
          if typeof p is "string"
            newExcludes.push validators.determinePath(p, config.serverTemplate.inPath)
          else
            errors.push "serverTemplate.exclude must be an array of strings"
            break
      config.serverTemplate.exclude = newExcludes


    packageJson = path.join process.cwd(), "package.json"
    if fs.existsSync packageJson
      version = require(packageJson).version
    version = "" unless version?

    defaultLocals =
      title:     "Mimosa"
      reload:    false
      optimize:  config.isOptimize
      cachebust: "?b=#{version}"

    if config.serverTemplate.locals?
      if typeof config.serverTemplate.locals is "object" and not Array.isArray(config.serverTemplate.locals)
        config.serverTemplate.locals = _.extend(defaultLocals, config.serverTemplate.locals)
      else
        errors.push "serverTemplate.locals must be an object"
    else
      config.serverTemplate.locals = defaultLocals


    if validators.ifExistsIsArray(errors, "serverTemplate.views", config.serverTemplate.views)
      for v in config.serverTemplate.views
        if v.path?
          v.path = validators.determinePath v.path, config.serverTemplate.inPath
          unless fs.existsSync v.path
            if fs.existsSync "#{v.path}.#{config.serverTemplate.extension}"
              v.path = "#{v.path}.#{config.serverTemplate.extension}"
            else
              errors.push "serverTemplate.views.path must exist, resolved to [[ #{v.path} ]]"
        else
          errors.push "serverTemplate.views.path must be a string"

        if v.locals?
          if typeof v.locals is "object" and not Array.isArray(v.locals)
            starterLocals = _.clone((config.serverTemplate.locals or defaultLocals), true)
            v.locals = _.extend(starterLocals, v.locals)
          else
            errors.push "serverTemplate.views.locals must be an object"
        else
          v.locals = config.serverTemplate.locals or defaultLocals


  errors