fs = require('fs')
ini = require('ini')

loadConfig = (configName, allowedMissing) ->
  try
    ini.parse(fs.readFileSync("./config/#{configName}.ini", "utf-8"))
  catch
    if allowedMissing
      logger.warn("#{configName}.ini not found in config folder root,
                   server might misbehave and some functions might be disabled.")
    else
      error = "#{configName}.ini not found in config folder root! Server cannot start."
      logger.error(error)
      throw error

if not process.env.TRAVIS
  global.mainConfig = loadConfig('config')
  global.dbConfig = if process.env.TESTMODE then loadConfig('database_test') else loadConfig('database')
  global.mailConfig = loadConfig('mail', true)
  global.solderConfig = loadConfig('solder', true)
else
  global.mainConfig = process.env.MAINCONFIG
  global.dbConfig = process.env.DBCONFIG
  global.mailConfig = process.env.MAILCONFIG
  global.solderConfig = process.env.SOLDERCONFIG
global.projectDir = __dirname
logger.info("Configuration loaded")