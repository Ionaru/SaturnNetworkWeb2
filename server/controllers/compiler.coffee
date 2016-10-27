fs = require('fs')
mkdirp = require('mkdirp')

exports.compileStylesheets = () ->
  startTime = Date.now()
  inputDirNameStyle = './client/style/'
  outputDirNameStyle = './client/public/stylesheets/'
  mkdirp(outputDirNameStyle)

  lessFile = fs.readFileSync(inputDirNameStyle + 'style.less', 'utf-8')
  Less = require('less')
  await Less.render(lessFile, {paths: inputDirNameStyle, filename: 'style.less'}, defer(err, output))
  fs.writeFileSync(outputDirNameStyle + 'style.css', output.css)
  CleanCSS = require('clean-css')
  source = fs.readFileSync(outputDirNameStyle + 'style.css', 'utf-8')
  minified = new CleanCSS().minify(source).styles
  fs.writeFileSync(outputDirNameStyle + 'style.css', minified)
  logger.info("Client-side stylesheets ready, took #{(Date.now() - startTime) / 1000} seconds")


exports.compileScripts = () ->
  startTime = Date.now()
  inputDirNameJS = './client/scripts/'
  outputDirNameJS = './client/public/javascript/'
  mkdirp(outputDirNameJS)

  Compiler = require('iced-coffee-script-3')
  coffeeFiles = fs.readdirSync(inputDirNameJS)
  if !fs.existsSync(outputDirNameJS)
    fs.mkdirSync(outputDirNameJS)
  fileContentJS = ""
  for file in coffeeFiles
    fileContent = fs.readFileSync(inputDirNameJS + file, 'utf-8')
    fileContentJS += Compiler.compile(fileContent)

  fs.writeFileSync(outputDirNameJS + 'saturn.js', fileContentJS)
  UglifyJS = require 'uglify-js'
  result = UglifyJS.minify(outputDirNameJS + 'saturn.js', outSourceMap: 'saturn.js.map')
  fs.writeFileSync(outputDirNameJS + 'saturn.js', result.code)
  fs.writeFileSync(outputDirNameJS + 'saturn.js.map', result.map)
  logger.info("Client-side javascript ready, took #{(Date.now() - startTime) / 1000} seconds")
