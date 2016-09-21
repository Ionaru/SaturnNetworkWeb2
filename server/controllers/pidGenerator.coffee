db = require './databaseConnector'

exports.generatePid = (pidLength = 6) ->
  if pidLength is 0
    pidLength = mainConfig['pid_length']
  pid = ''
  possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  i = 0
  while i < pidLength
    pid += possible.charAt(Math.floor(Math.random() * possible.length))
    i++
  pid

exports.generateUniqueUserPid = (done, pidLength = 10) ->
  pid = exports.generatePid pidLength
  db.get().query "SELECT user_pid FROM users WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      done(err)
    if rows.length > 0
      exports.generateUniqueUserPid done, pidLength
    else
      done null, pid
