"use strict";
var fs, path, _;

fs = require("fs");

path = require("path");

_ = require("lodash");

exports.defaults = function() {
  return {
    serverTemplate: {
      exclude: ["layout.jade"],
      locals: {
        title: "Mimosa",
        reload: false
      }
    }
  };
};

exports.placeholder = function() {
  return "\t\n\n  ###\n  # This is not the full set of serverTemplate defaults as many defaults are assumed from other\n  # config settings in your application. To see a complete breakdown of all the serverTemplate\n  # config options (there are many), visit https://github.com/dbashford/mimosa-server-template-compile\n  ###\n  serverTemplate:\n    exclude: [\"layout.jade\"]     # files to exclude from compilation\n    locals:                      # a list of properties to pass into all the templates when\n                                 # they are compiled, the following defaults match properties\n                                 # that are used in the default 'mimosa new' projects\n      title: \"Mimosa\"            # title of the page\n      reload: false              # flag for whether or not to include live reload, which does\n                                 # not make sense for compiled templates\n";

  /*
   */
};

exports.validate = function(config, validators) {
  var defaultLocals, errors, newExcludes, p, packageJson, starterLocals, v, version, _i, _j, _len, _len1, _ref, _ref1;
  errors = [];
  if (validators.ifExistsIsObject(errors, "serverTemplate config", config.serverTemplate)) {
    if (config.serverTemplate.compileWith != null) {
      if (typeof config.serverTemplate.compileWith === "string") {
        if (['jade', 'hogan.js', 'handlebars', 'ejs'].indexOf(config.serverTemplate.compileWith) === -1) {
          errors.push("serverTemplate.compileWith must be one of: 'jade', 'hogan.js', 'handlebars', 'ejs'");
        }
      } else {
        errors.push("serverTemplate.compileWith must be a string");
      }
    } else {
      config.serverTemplate.compileWith = config.server.views.compileWith != null ? config.server.views.compileWith : "jade";
    }
    if (config.serverTemplate.extension != null) {
      if (typeof config.serverTemplate.extension !== "string") {
        errors.push("serverTemplate.extension must be a string");
      }
    } else {
      config.serverTemplate.extension = config.server.views.extension != null ? config.server.views.extension : "jade";
    }
    if (config.serverTemplate.inPath != null) {
      if (typeof config.serverTemplate.inPath !== "string") {
        errors.push("serverTemplate.inPath must be a string");
      }
    } else {
      config.serverTemplate.inPath = config.server.views.path != null ? config.server.views.path : "views";
    }
    if (errors.length === 0) {
      config.serverTemplate.inPath = validators.determinePath(config.serverTemplate.inPath, config.root);
      if (!fs.existsSync(config.serverTemplate.inPath)) {
        errors.push("serverTemplate.inPath must exist, was resolved to [[ " + config.serverTemplate.inPath + " ]]");
      }
    }
    if (config.serverTemplate.outPath != null) {
      if (typeof config.serverTemplate.outPath !== "string") {
        errors.push("serverTemplate.outPath must be a string");
      }
    } else {
      config.serverTemplate.outPath = config.watch.compiledDir;
    }
    if (errors.length === 0) {
      config.serverTemplate.outPath = validators.determinePath(config.serverTemplate.outPath, config.root);
      if (!fs.existsSync(config.serverTemplate.outPath)) {
        errors.push("serverTemplate.outPath must exist, was resolved to [[ " + config.serverTemplate.outPath + " ]]");
      }
    }
    if (validators.ifExistsIsArray(errors, "serverTemplate.exclude", config.serverTemplate.exclude)) {
      newExcludes = [];
      _ref = config.serverTemplate.exclude;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        if (errors.length === 0) {
          if (typeof p === "string") {
            newExcludes.push(validators.determinePath(p, config.serverTemplate.inPath));
          } else {
            errors.push("serverTemplate.exclude must be an array of strings");
            break;
          }
        }
      }
      config.serverTemplate.exclude = newExcludes;
    }
    packageJson = path.join(process.cwd(), "package.json");
    if (fs.existsSync(packageJson)) {
      version = require(packageJson).version;
    }
    if (version == null) {
      version = "";
    }
    defaultLocals = {
      title: "Mimosa",
      reload: false,
      optimize: config.isOptimize,
      cachebust: "?b=" + version
    };
    if (config.serverTemplate.locals != null) {
      if (typeof config.serverTemplate.locals === "object" && !Array.isArray(config.serverTemplate.locals)) {
        config.serverTemplate.locals = _.extend(defaultLocals, config.serverTemplate.locals);
      } else {
        errors.push("serverTemplate.locals must be an object");
      }
    } else {
      config.serverTemplate.locals = defaultLocals;
    }
    if (validators.ifExistsIsArray(errors, "serverTemplate.views", config.serverTemplate.views)) {
      _ref1 = config.serverTemplate.views;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        v = _ref1[_j];
        if (v.path != null) {
          v.path = validators.determinePath(v.path, config.serverTemplate.inPath);
          if (!fs.existsSync(v.path)) {
            if (fs.existsSync("" + v.path + "." + config.serverTemplate.extension)) {
              v.path = "" + v.path + "." + config.serverTemplate.extension;
            } else {
              errors.push("serverTemplate.views.path must exist, resolved to [[ " + v.path + " ]]");
            }
          }
        } else {
          errors.push("serverTemplate.views.path must be a string");
        }
        if (v.locals != null) {
          if (typeof v.locals === "object" && !Array.isArray(v.locals)) {
            starterLocals = _.clone(config.serverTemplate.locals || defaultLocals, true);
            v.locals = _.extend(starterLocals, v.locals);
          } else {
            errors.push("serverTemplate.views.locals must be an object");
          }
        } else {
          v.locals = config.serverTemplate.locals || defaultLocals;
        }
      }
    }
  }
  return errors;
};
