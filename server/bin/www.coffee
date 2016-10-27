# coffeelint: disable=no_debugger
if not process.env.SILENT
  console.log("Loaded into IcedCoffeeScript")
  console.log("Starting setup")
# coffeelint: enable=no_debugger

require('../controllers/logger')
require('../controllers/configLoader')

###
# Prepare stylesheets and scripts for client use
###
compiler = require('../controllers/compiler')
compiler.compileStylesheets()
compiler.compileScripts()

###
# Init application
###
app = require('../app')
app.enable('trust proxy')

###*
# Get port from environment and store in Express.
###
port = process.env.PORT or '3000'
app.set('port', port)

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
      logger.error(bind + ' requires elevated privileges')
      process.exit(1)
    when 'EADDRINUSE'
      logger.error(bind + ' is already in use')
      process.exit(1)
    else
      throw error
  return

###*
# Event listener for HTTP server "listening" event.
###
onListening = ->
  addr = server.address()
  bind = if typeof addr == 'string' then 'pipe ' + addr else 'port ' + addr.port
  logger.info('Finished setup')
  logger.info('Listening on ' + bind)
  return

###*
# Create HTTP server.
###
http = require('http')
server = http.createServer(app)

###*
# Listen on provided port, on all network interfaces.
###
server.listen(port)
server.on('error', onError)
server.on('listening', onListening)

exitHandler = (options, err) ->
  if options.cleanup
    logger.warn('Shutdown complete, goodbye!')
    logger.log()
  if err
    logger.error(err.stack)
  if options.exit
    logger.warn('Got shutdown command, executing shutdown tasks.')
    process.exit()
  return

process.stdin.resume()
#do something when app is closing
process.on('exit', exitHandler.bind(null, cleanup: true))
#catches ctrl+c event
process.on('SIGINT', exitHandler.bind(null, exit: true))
#catches uncaught exceptions
process.on('uncaughtException', exitHandler.bind(null, exit: true))
