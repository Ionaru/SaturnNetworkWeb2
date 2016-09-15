fs = require 'fs'
now = new Date

logDirs =
  info: "./logs/info/"
  warn: "./logs/warning/"
  error: "./logs/error/"

logFilePath = logDirs.info + "_plain.txt"
warnFilePath = logDirs.warn + "_plain.txt"
errFilePath = logDirs.error + "_plain.txt"
logFileJSONPath = logDirs.info + "_json.txt"
warnFileJSONPath = logDirs.warn + "_json.txt"
errFileJSONPath = logDirs.error + "_json.txt"

for k, logDir of logDirs
  require('mkdirp').sync logDir, (err) ->
    console.log "creating ", logDir

winston = require 'winston'
consoleLog = new (winston.transports.Console)(
  level: 'info'
  timestamp: ->
    getLogTimeStamp()
  colorize: true)

fileLog = new (require('winston-daily-rotate-file'))(
  name: 'file#log'
  datePattern: "log_yyyy-MM-dd"
  level: 'info'
  prepend: true
  timestamp: ->
    getLogTimeStamp()
  filename: logFilePath
  json: false)

fileWarn = new (require('winston-daily-rotate-file'))(
  name: 'file#warn'
  datePattern: "log_yyyy-MM-dd"
  level: 'warn'
  prepend: true
  timestamp: ->
    getLogTimeStamp()
  filename: warnFilePath
  json: false)

fileError = new (require('winston-daily-rotate-file'))(
  name: 'file#error'
  datePattern: "log_yyyy-MM-dd"
  level: 'error'
  prepend: true
  timestamp: ->
    getLogTimeStamp()
  filename: errFilePath
  json: false)

JsonLog = new (require('winston-daily-rotate-file'))(
  name: 'file#JsonLog'
  datePattern: "log_yyyy-MM-dd"
  level: 'info'
  prepend: true
  timestamp: ->
    getLogTimeStamp()
  filename: logFileJSONPath)

JsonWarn = new (require('winston-daily-rotate-file'))(
  name: 'file#JsonWarn'
  datePattern: "log_yyyy-MM-dd"
  level: 'warn'
  prepend: true
  timestamp: ->
    getLogTimeStamp()
  filename: warnFileJSONPath)

JsonError = new (require('winston-daily-rotate-file'))(
  name: 'file#JsonError'
  datePattern: "log_yyyy-MM-dd"
  level: 'error'
  prepend: true
  timestamp: ->
    getLogTimeStamp()
  filename: errFileJSONPath)

global.logger = new (winston.Logger)(transports: [
  consoleLog
  fileLog, fileWarn, fileError
  JsonLog, JsonWarn, JsonError
])

getLogTimeStamp = ->
  now = new Date
  year = now.getFullYear()
  month = ('0' + (now.getMonth() + 1)).slice(-2)
  day = ('0' + now.getDate()).slice(-2)
  hour = ('0' + now.getHours()).slice(-2)
  minute = ('0' + now.getMinutes()).slice(-2)
  second = ('0' + now.getSeconds()).slice(-2)
  date = [year, month, day].join('-')
  time = [hour, minute, second].join(':')
  return [date, time].join ' '

logger.info 'Logger enabled and taking over!'