g = require 'gulp'
$ = require('gulp-load-plugins')()
pkg = require './package.json'

path =
  html: 'src/**/*.html'
  css: ['src/css/**/*.{scss,css}', '!src/css/bootstrap/bootstrap.scss']
  js: 'src/js/*.js'
  img: 'src/**/img/*.{jpg,png,gif}'

banner = '/*!\n' +
  ' * <%= pkg.name %> v<%= pkg.version %>\n' +
  ' * Copyright ' + $.util.date('yyyy') + ' <%= pkg.author %>\n' +
  ' * Licensed under <%= pkg.license %> License\n' +
  ' */\n'

g.task 'default', ['html', 'css', 'js', 'watch']

g.task 'init', ->
  g.src [
    'bower/bootstrap-sass-official/vendor/assets/stylesheets/**'
    'bower/bootstrap-accessibility-plugin/plugins/css/**'
  ]
  .pipe g.dest 'src/css'
  g.src 'bower/bootstrap-sass-official/vendor/assets/fonts/**'
  .pipe g.dest 'dist/css'
  g.src [
    'bower/bootstrap/dist/js/bootstrap.js'
    'bower/bootstrap-accessibility-plugin/plugins/js/bootstrap-accessibility.js'
  ]
  .pipe $.concat 'bootstrap.all.js'
  .pipe g.dest 'src/js'
  g.src 'bower/jquery/dist/jquery.min.js'
  .pipe g.dest 'dist/js'

g.task 'connect', ->
  $.connect.server
    root: 'dist'
    port: 1337
    livereload: true

g.task 'html', ->
  g.src path.html
  .pipe $.changed 'dist'
  .pipe $.htmlmin collapseWhitespace: true, removeComments: true
  .pipe g.dest 'dist'

g.task 'css', ->
  g.src path.css
  .pipe $.plumber()
  .pipe $.rubySass style: 'expanded'
  .pipe $.concat 'all.css'
  .pipe $.autoprefixer 'last 2 version', 'ios >= 5', 'android >= 2.3'
  .pipe $.header banner, pkg: pkg
  .pipe g.dest 'dist/css'
  .pipe $.rename suffix: '.min'
  .pipe $.combineMediaQueries()
  .pipe $.csso()
  .pipe g.dest 'dist/css'

g.task 'js', ->
  g.src path.js
  .pipe $.concat 'all.js'
  .pipe $.header banner, pkg: pkg
  .pipe g.dest 'dist/js'
  .pipe $.rename suffix: '.min'
  .pipe $.uglify()
  .pipe $.header banner, pkg: pkg
  .pipe g.dest 'dist/js'

g.task 'img', ->
  g.src path.img
  .pipe $.imagemin()
  .pipe g.dest 'dist'

g.task 'watch', ['connect'], ->
  g.watch path.css, ['css']
  g.watch path.js,  ['js']
  g.watch path.img, ['img']
  g.watch path.html,['html']
  g.watch 'dist/**/*.*', (e) ->
    g.src e.path
    .pipe $.connect.reload()

module.exports = g