db = require('./databaseConnector')

exports.generatePid = (pidLength) ->
  pid = ''
  possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  i = 0
  while i < pidLength
    pid += possible.charAt(Math.floor(Math.random() * possible.length))
    i++
  return pid

exports.generateUniqueUserPid = (done, pidLength = 10) ->
  pid = exports.generatePid(pidLength)
  await db.get().query("SELECT user_pid FROM users WHERE user_pid = \"#{pid}\";", defer(err, rows))
  if err
    done(err)
  if rows.length > 0
    exports.generateUniqueUserPid(done, pidLength)
  else
    return done(null, pid)
