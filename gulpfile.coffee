g = require 'gulp'
$ = require('gulp-load-plugins')()
bs = require 'browser-sync'
sq = require 'streamqueue'
pkg = require './package.json'

path =
  html: 'src/**/*.html'
  css: 'src/css/**/*.{scss,css}'
  js: 'src/js/*.js'
  img: 'src/**/img/*.{jpg,png,gif}'

banner = '/*!\n' +
  ' * <%= pkg.name %> v<%= pkg.version %>\n' +
  ' * Copyright ' + new Date().getFullYear() + ' <%= pkg.author %>\n' +
  ' * Licensed under <%= pkg.license %> License\n' +
  ' */\n'

g.task 'init', ->
  g.src [
    'bower/bootstrap-sass-official/vendor/assets/stylesheets/**'
    'bower/bootstrap-accessibility-plugin/plugins/css/**'
  ]
  .pipe g.dest 'src/css'
  g.src 'bower/bootstrap-sass-official/vendor/assets/fonts/**'
  .pipe g.dest 'dist/css'
  g.src [
    'bower/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/*.js'
    'bower/bootstrap-accessibility-plugin/plugins/js/bootstrap-accessibility.js'
  ]
  .pipe $.concat 'bootstrap.all.js'
  .pipe g.dest 'src/js'
  g.src 'bower/jquery/dist/jquery.min.js'
  .pipe g.dest 'dist/js'

g.task 'bs', ->
  bs.init null,
    server:
      baseDir: 'dist'

g.task 'html', ->
  g.src path.html
  .pipe $.changed 'dist'
  .pipe $.htmlmin collapseWhitespace: true, removeComments: true
  .pipe g.dest 'dist'
  .pipe bs.reload stream: true

g.task 'css', ->
  sq objectMode: true,
    g.src 'src/css/bootstrap.scss'
    .pipe $.plumber()
    .pipe $.sass style: 'expanded'
    g.src 'src/css/*.css'
  .pipe $.concat 'all.css'
  .pipe $.autoprefixer 'last 2 version', 'ios >= 5', 'android >= 2.3'
  .pipe $.header banner, pkg: pkg
  .pipe g.dest 'dist/css'
  .pipe $.rename suffix: '.min'
  .pipe $.combineMediaQueries()
  .pipe $.csso()
  .pipe g.dest 'dist/css'
  .pipe bs.reload stream: true

g.task 'js', ->
  g.src path.js
  .pipe $.concat 'all.js'
  .pipe $.header banner, pkg: pkg
  .pipe g.dest 'dist/js'
  .pipe $.rename suffix: '.min'
  .pipe $.uglify()
  .pipe $.header banner, pkg: pkg
  .pipe g.dest 'dist/js'
  .pipe bs.reload stream: true, once: true

g.task 'img', ->
  g.src path.img
  .pipe $.changed 'dist'
  .pipe $.imagemin()
  .pipe g.dest 'dist'
  .pipe bs.reload stream: true, once: true

g.task 'default', ['bs', 'html', 'css', 'js'], ->
  g.watch path.css,  ['css']
  g.watch path.js,   ['js']
  g.watch path.img,  ['img']
  g.watch path.html, ['html']