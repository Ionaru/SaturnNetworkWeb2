fs = require('fs')
mkdirp = require('mkdirp')

exports.compileStylesheets = (done) ->
  startTime = Date.now()
  inputDirNameStyle = './client/style/'
  outputDirNameStyle = './client/public/stylesheets/'
  mkdirp.sync(outputDirNameStyle)

  sass = require('node-sass')
  result = sass.renderSync(
    file: inputDirNameStyle + 'style.scss'
    outputStyle: 'compressed'
    outFile: outputDirNameStyle + 'style.css'
    sourceMap: devMode
  )
  fs.writeFileSync(outputDirNameStyle + 'style.css', result.css)
  if devMode
    fs.writeFileSync(outputDirNameStyle + 'style.css.map', result.map)
  logger.info("Client-side stylesheets ready, took #{(Date.now() - startTime) / 1000} seconds")
  return done()

exports.compileScripts = (done) ->
  startTime = Date.now()
  inputDirNameJS = './client/scripts/'
  outputDirNameJS = './client/public/javascript/'
  mkdirp.sync(outputDirNameJS)

  Compiler = require('iced-coffee-script-3')
  coffeeFiles = fs.readdirSync(inputDirNameJS)
  fileContent = ''
  for file in coffeeFiles
    fileContent += fs.readFileSync(inputDirNameJS + file, 'utf-8') + '\n'
  fileContentJS = Compiler.compile(fileContent)
  fs.writeFileSync(outputDirNameJS + 'saturn.js', fileContentJS)

  if prodMode
    UglifyJS = require 'uglify-js'
    result = UglifyJS.minify(outputDirNameJS + 'saturn.js')
    fs.writeFileSync(outputDirNameJS + 'saturn.js', result.code)
  logger.info("Client-side javascript ready, took #{(Date.now() - startTime) / 1000} seconds")
  return done()
