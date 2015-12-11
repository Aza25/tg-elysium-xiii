### Settings ###
min = require("gulp-util").env.min

# Project Paths
paths =
  images:    "images/"
  scripts:   "scripts/*.coffee"
  styles:    "styles/*.less"
  templates: "templates/*.dot"
  build:     "assets"

# doT Settings
dotOpts =
  evaluate:      /\{\{([\s\S]+?)\}\}/g,
  interpolate:   /\{\{=([\s\S]+?)\}\}/g,
  encode:        /\{\{!([\s\S]+?)\}\}/g,
  use:           /\{\{#([\s\S]+?)\}\}/g,
  define:        /\{\{##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\}\}/g,
  conditional:   /\{\{\?(\?)?\s*([\s\S]*?)\s*\}\}/g,
  iterate:       /\{\{~\s*(?:\}\}|([\s\S]+?)\s*\:\s*([\w$]+)\s*(?:\:\s*([\w$]+))?\s*\}\})/g,
  varname:       "data, config, helper",
  strip:         true,
  append:        true,
  selfcontained: true

# LESS Settings
lessOpts =
  paths: [paths.images]

# Autoprefixer Settings
autoOpts =
    browsers: [
        "last 2 versions",
        "> 5%",
        "ie >= 8"
    ]

# CSSNano Settings
nanoOpts =
  discardComments:
    removeAll: true

# Filter Settings
filterOpts =
    oldIE: true


### Gulp ###
gulp       = require "gulp"
gulpif     = require "gulp-if"
jsbeautify = require "gulp-jsbeautifier"
bower      = require "main-bower-files"
coffee     = require "gulp-coffee"
concat     = require "gulp-concat"
csscomb    = require "gulp-csscomb"
cssnano    = require "gulp-cssnano"
del        = require "del"
dot        = require "gulp-dot-precompiler"
header     = require "gulp-header"
filter     = require "gulp-filter"
gutil      = require "gulp-util"
less       = require "gulp-less"
merge      = require "merge-stream"
postcss    = require "gulp-postcss"
replace    = require "gulp-replace"
uglify     = require "gulp-uglify"

### PostCSS ###

autoprefixer = require "autoprefixer"
clearfix     = require "postcss-clearfix"
filters      = require "pleeease-filters"
gradient     = require "postcss-filter-gradient"
opacity      = require "postcss-opacity"
pseudo       = require "postcss-pseudoelements"
rgba         = require "postcss-color-rgba-fallback"


### Tasks ###
gulp.task "default", ["fonts", "scripts", "styles", "templates"]

gulp.task "clean", ->
  del "#{paths.build}/*"

gulp.task "watch", ->
  gulp.watch paths.scripts, ["scripts"]
  gulp.watch paths.styles, ["styles"]
  gulp.watch paths.templates, ["templates"]

gulp.task "fonts", ->
  gulp.src bower "**/*.{eot,woff{,2}}"
    .pipe gulp.dest paths.build

gulp.task "scripts", ->
  lib = gulp.src bower "**/*.js"
    .pipe concat("lib.js")
    .pipe gulpif(min, uglify(), jsbeautify())
    .pipe gulp.dest paths.build

  nanoui = gulp.src paths.scripts
    .pipe coffee()
    .pipe concat("app.js")
    .pipe gulpif(min, uglify(), jsbeautify())
    .pipe gulp.dest paths.build

  merge lib, nanoui

gulp.task "styles", ->
  lib = gulp.src bower "**/*.css"
    .pipe replace("../fonts/", "")
    .pipe concat("lib.css")
    .pipe gulpif(min, cssnano(nanoOpts), csscomb())
    .pipe gulp.dest paths.build

  nanoui = gulp.src paths.styles
    .pipe filter(["*.less", "!_*.less"])
    .pipe less(lessOpts)
    .pipe postcss([
      autoprefixer(autoOpts),
      filters(filterOpts)
      pseudo,
      rgba,
      gradient,
      opacity,
      clearfix
    ])
    .pipe gulpif(min, cssnano(nanoOpts), csscomb())
    .pipe gulp.dest paths.build

  merge lib, nanoui

gulp.task "templates", ->
  gulp.src paths.templates
    .pipe dot({dictionary: "TMPL", templateSettings: dotOpts})
    .pipe concat("templates.js")
    .pipe header("window.TMPL = {};\n")
    .pipe gulpif(min, uglify(), jsbeautify())
    .pipe gulp.dest paths.build
