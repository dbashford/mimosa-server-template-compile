"use strict";
var config, cons, fs, logger, path, registration, wrench, _, __genCompileFiles, __genOutFileName, __getLocals, __writeOutputFile, _clean, _compileTemplates;

path = require("path");

fs = require("fs");

wrench = require("wrench");

cons = require('consolidate');

_ = require("lodash");

config = require('./config');

logger = null;

registration = function(mimosaConfig, register) {
  logger = mimosaConfig.log;
  if (mimosaConfig.isBuild) {
    register(['postBuild'], 'beforePackage', _compileTemplates);
  }
  return register(['preClean'], 'init', _clean);
};

_compileTemplates = function(mimosaConfig, options, next) {
  var compileFiles, done, i, st;
  st = mimosaConfig.serverTemplate;
  compileFiles = __genCompileFiles(st);
  if (!((compileFiles != null ? compileFiles.length : void 0) > 0)) {
    return next();
  }
  i = 0;
  done = function() {
    if (++i === compileFiles.length) {
      return next();
    }
  };
  return compileFiles.forEach(function(f) {
    var locals;
    locals = __getLocals(st, f);
    logger.debug("server-template-compile compiling [[ " + f + " ]]");
    return cons[st.compileWith](f, locals, function(err, html) {
      if (err) {
        logger.error("Compilation failed on file [[ " + f + " ]]:\n" + err);
        return done();
      } else {
        return __writeOutputFile(st, f, html, done);
      }
    });
  });
};

_clean = function(mimosaConfig, options, next) {
  var compileFiles, done, i, st;
  st = mimosaConfig.serverTemplate;
  compileFiles = __genCompileFiles(st);
  if (!((compileFiles != null ? compileFiles.length : void 0) > 0)) {
    return next();
  }
  i = 0;
  done = function() {
    if (++i === compileFiles.length) {
      return next();
    }
  };
  return compileFiles.forEach(function(f) {
    var outFileName;
    outFileName = __genOutFileName(st.outPath, st.inPath, f);
    return fs.exists(outFileName, function(exists) {
      if (exists) {
        return fs.unlink(outFileName, function() {
          logger.success("Deleted compiled template [[ " + outFileName + " ]]");
          return done();
        });
      } else {
        return done();
      }
    });
  });
};

__getLocals = function(st, f) {
  var locals, locs, v;
  locals = (function() {
    var _i, _len, _ref;
    if (st.views != null) {
      locs = st.locals;
      _ref = st.views;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        if (v.path === f && (v.locals != null)) {
          locs = v.locals;
          break;
        }
      }
      return locs;
    } else {
      return st.locals;
    }
  })();
  return _.clone(locals, true);
};

__writeOutputFile = function(st, f, html, cb) {
  var dirname, outFileName;
  outFileName = __genOutFileName(st.outPath, st.inPath, f);
  dirname = path.dirname(outFileName);
  return fs.exists(dirname, function(exists) {
    if (!exists) {
      logger.debug("server-template-compile making directory [[ " + dirname + " ]]");
      wrench.mkdirSyncRecursive(dirname, 0x1ff);
    }
    return fs.writeFile(outFileName, html, "utf8", function(err) {
      if (err) {
        logger.error("Error writing [[ " + outFileName + " ]]");
      } else {
        logger.success("server-template-compile wrote file [[ " + outFileName + " ]]");
      }
      return cb();
    });
  });
};

__genCompileFiles = function(config) {
  var allFiles, compileFiles;
  allFiles = wrench.readdirSyncRecursive(config.inPath).map(function(f) {
    return path.join(config.inPath, f);
  });
  compileFiles = allFiles.filter(function(f) {
    return config.exclude.indexOf(f) === -1;
  });
  return compileFiles = compileFiles.filter(function(f) {
    return path.extname(f) === ("." + config.extension);
  });
};

__genOutFileName = function(outPath, inPath, f) {
  var outFileName;
  outFileName = path.join(outPath, f.replace(inPath, ""));
  return outFileName.replace(path.extname(outFileName), ".html");
};

module.exports = {
  registration: registration,
  defaults: config.defaults,
  placeholder: config.placeholder,
  validate: config.validate
};
