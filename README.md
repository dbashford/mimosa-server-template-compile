mimosa-server-template-compile
===========

## Overview

This Mimosa module will find and compile server templates as part of a Mimosa build.

For more information regarding Mimosa, see http://mimosajs.com

## Usage

Add `'server-template-compile'` to your list of modules.  That's all!  Mimosa will install the module for you when you start up.

## Functionality

This module will, as part of a `mimosa build`, compile your dynamic templates into `.html` files.  Use this module if you want to take advantage of Mimosa's serving of dynamic templates, but do not intend to deploy node to your target environment and therefore cannot dynamically compile templates at runtime.  This also enables building of static websites using dynamic assets.

The server template languages supported by Mimosa are supported by this module. Those include:

* Jade (default)
* Hogan
* EJS
* Handlebars

This module replaces the old `--jade` flag that was a part of `mimosa build` pre version 0.7.0.

## Default Config

The default config for this module is almost entirely derived from other settings and properties in a project.  Some are from other Mimosa module settings, some from flags used during `mimosa build`, others from the project's package.json.  Those settings are indicated below after an arrow `=>`.

The full default config:

```
serverTemplate:
  compileWith: => server.views.compileWith or 'jade'
  extension: => server.views.extension or 'jade'
  inPath: => server.views.path or 'views'
  outPath: => server.watch.compiledDir
  exclude: ["layout.jade"]
  locals:
    title:     "Mimosa"
    reload:    false
    optimize:  => whether or not the --optimize flag is used
    cachebust: => project's package.json.version or ""
```

* `compileWith`: a string, the name of the compiler to use for the server views.  Defaults to the setting located at `server.views.compileWith`.  If that setting isn't present, it defaults to `jade`.  Possible values are: `jade`, `hogan.js`, `handlebars`, `ejs`.
* `extension`: a string, the extension of the files to compile.  Defaults to the setting located at `server.views.extension`.  If that setting isn't present, it defaults to `jade`.
* `inPath`: a string, the path to the folder containing the server templates. Defaults to the setting located at `server.views.path`.  If that setting isn't present, it defaults to `views`.  Path can be absolute or relative to the root of the project.
* `outPath`: a string, the path to the folder to which the the templates will be compiled. Defaults to the `server.watch.compiledDir`.  Path can be absolute or relative to the root of the project.
* `exclude`: an array of strings, a list of files to not compile.  Paths can be relative to `inPath` or absolute. Defaults to `['layout.jade']`. File paths do not need to exist.
* `locals`: an object, the JSON object to pass into the server templates when they are compiled. By default, the same JSON object is passed into all templates.  An alternative configuration exists where objects can be defined on a per template basis.  See below.
* `locals.title`: a string, defaults to `Mimosa`.  If you are using `title` in your views, you'll like want to change this away from `Mimosa`
* `locals.reload`: a boolean, defaults to `false`.  It doesn't much sense to use live reload as part of a build, so this is set to false. If you are not using `mimosa-live-reload`, this setting has no effect.
* `locals.optimize`: a boolean, defaults to the whether or not the `--optimize` flag is used as part of the build.  If the flag is used, this setting is `true`.
* `locals.cachebust`: a string, the string to tack onto asset urls in the compiled `.html`.  By default this is set to `?` followed by the value of the project's package.json version property.  If that does not exist, it is set to an empty string. Often when building and deploying an app, you want to cachebust the assets, but only for each version of the application that gets deployed rather than with every load of the page.  This accomplishes that.

The derived settings above are assumed, making the actual `mimosa-config` defaults the following:

```
serverTemplate:
  exclude: ["layout.jade"]
  locals:
    title: "Mimosa"
    reload: false
```

If you are using jade, and using `mimosa-server`, and have templates that do not vary far from those delivered by `mimosa new`, then all you may need to do is change the `locals.title` property.  For example:

```
serverTemplate:
  locals:
    title: "MyAppName"
```

## Alternate Config

Your templates may not all take the same parameters.  The config is flexible enough to allow you to pass in different parameters per template.

```
serverTemplate:
  compileWith: => server.views.compileWith or 'jade'
  extension: => server.views.extension or 'jade'
  inPath: => server.views.path or 'views'
  outPath: => server.watch.compiledDir
  exclude: ["layout.jade"]
  locals:
    title:     "Mimosa"
    reload:    false
    optimize:  => whether or not the --optimize flag is used
    cachebust: => project's package.json.version
  views: [{
    path: "foo.jade" <= no default
    locals:
      title:     "Mimosa"
      reload:    false
      optimize:  => whether or not the --optimize flag is used
      cachebust: => project's package.json.version or ""
  }]
```

Additional fields in this config:

* `views`: a list of views to compile
* `views.path`: a string, a path to a view. The `path` can be absolute, or relative to the `inPath`. The `path` should match the name of a template and can include or not include the extension. The `path` must exist.
* `views.locals`: an object, object properties to pass into the template compilation.  All of the defaults for `locals` listed above (`title`, `reload`, `optimize`, and `cachebust`) are assumed for each entry in the `views` array. Any view encountered that is not in the array of views will get the root `locals` passed in to compilation. Any top-level `locals` are inherited by `locals` in the `views` array.
