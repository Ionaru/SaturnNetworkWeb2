console.log "Loaded into IcedCoffeeScript"
console.log "Starting setup"

require('../controllers/logger')
require('../controllers/configLoader')

###
# Compile stylesheets and javascript files for client use
###
fs = require('fs')
inputDirNameStyle = './client/style/'
outputDirNameStyle = './client/public/stylesheets/'
inputDirNameJS = './client/scripts/'
outputDirNameJS = './client/public/javascript/'
require('mkdirp') outputDirNameStyle
require('mkdirp') outputDirNameJS
lessFile = fs.readFileSync(inputDirNameStyle + 'style.less', 'utf-8')
Less = require 'less'
Less.render lessFile, {paths: inputDirNameStyle, filename: 'style.less'}, (e, output) ->
  if not e
    fs.writeFileSync(outputDirNameStyle + 'style.css', output.css)
    CleanCSS = require 'clean-css'
    source = fs.readFileSync(outputDirNameStyle + 'style.css', 'utf-8')
    minified = new CleanCSS().minify(source).styles
    fs.writeFileSync(outputDirNameStyle + 'style.css', minified)
    logger.info "Client-side stylesheets ready"

    Compiler = require 'coffee-script'
    coffeeFiles = fs.readdirSync(inputDirNameJS)
    if !fs.existsSync(outputDirNameJS)
      fs.mkdirSync outputDirNameJS
    fileContentJS = ""
    for file in coffeeFiles
      fileContent = fs.readFileSync(inputDirNameJS + file, 'utf-8')
      fileContentJS += Compiler.compile(fileContent)

    fs.writeFileSync(outputDirNameJS + 'saturn.js', fileContentJS)
#    UglifyJS = require 'uglify-js'
#    result = UglifyJS.minify(outputDirNameJS + 'saturn.js', outSourceMap: 'saturn.js.map')
#    fs.writeFileSync(outputDirNameJS + 'saturn.js', result.code)
#    fs.writeFileSync(outputDirNameJS + 'saturn.js.map', result.map)
    logger.info "Client-side javascript ready"


    ###
    # Init application
    ###
    app = require('../app')
    app.enable('trust proxy')

    ###*
    # Get port from environment and store in Express.
    ###

    port = process.env.PORT or '3000'

    ###*
    # Event listener for HTTP server "error" event.
    ###

    onError = (error) ->
      if error.syscall != 'listen'
        throw error
      bind = if typeof port == 'string' then 'Pipe ' + port else 'Port ' + port
      # handle specific listen errors with friendly messages
      switch error.code
        when 'EACCES'
          logger.error bind + ' requires elevated privileges'
          process.exit 1
        when 'EADDRINUSE'
          logger.error bind + ' is already in use'
          process.exit 1
        else
          throw error
      return

    ###*
    # Event listener for HTTP server "listening" event.
    ###

    onListening = ->
      addr = server.address()
      bind = if typeof addr == 'string' then 'pipe ' + addr else 'port ' + addr.port
      logger.info 'Finished setup'
      logger.info 'Listening on ' + bind
      return

    app.set 'port', port

    ###*
    # Create HTTP server.
    ###

    http = require('http')
    server = http.createServer(app)

    ###*
    # Listen on provided port, on all network interfaces.
    ###

    server.listen port
    server.on 'error', onError
    server.on 'listening', onListening

    exitHandler = (options, err) ->
      if options.cleanup
        logger.warn 'Shutdown complete, goodbye!'
        logger.log()
      if err
        logger.error err.stack
      if options.exit
        logger.warn 'Got shutdown command, executing shutdown tasks.'
        process.exit()
      return

    process.stdin.resume()
    #do something when app is closing
    process.on 'exit', exitHandler.bind(null, cleanup: true)
    #catches ctrl+c event
    process.on 'SIGINT', exitHandler.bind(null, exit: true)
    #catches uncaught exceptions
    process.on 'uncaughtException', exitHandler.bind(null, exit: true)
  else
    throw e
