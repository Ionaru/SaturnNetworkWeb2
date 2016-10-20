fs = require('fs')
ini = require('ini')

loadConfig = (configName, allowedMissing) ->
  try
    if process.env.TESTMODE
      ini.parse(fs.readFileSync("./config/#{configName}_test.ini", "utf-8"))
    else
      ini.parse(fs.readFileSync("./config/#{configName}.ini", "utf-8"))
  catch
    if allowedMissing
      logger.warn("#{configName}.ini not found in config folder root,
                   server might misbehave and some functions might be disabled.")
    else
      error = "#{configName}.ini not found in config folder root! Server cannot start."
      logger.error(error)
      throw error

global.mainConfig = loadConfig('config')
global.dbConfig = loadConfig('database')
global.mailConfig = loadConfig('mail', true)
global.solderConfig = loadConfig('solder', true)
global.projectDir = __dirname
logger.info("Configuration loaded")
