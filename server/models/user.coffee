db = require '../controllers/databaseConnector'
pidGen = require '../controllers/pidGenerator'
validator = require '../controllers/validationHelper'
bcrypt = require 'bcrypt-nodejs'

exports.create = (username, email, password, done) ->
  pidGen.generateUniqueUserPid (err, pid) ->
# Validate input again, just to be on the safe side
    if validator.validateUsername(username) and validator.validatePassword(password) and validator.validateEmail(email)
      password = bcrypt.hashSync(password)
      values = [
        pid
        username
        password
        email
        new Date
      ]
      db.get().query "INSERT INTO users (user_pid, user_name, user_password_hash, user_email, user_registerdate) VALUES(?, ?, ?, ?, ?)", values, (err, result) ->
        if err
          return done err
        done null, pid
    else
      return done("validation_error")

exports.getColumns = (columns, order=false, done) ->
  if order
    orderString = "ORDER BY #{order}"
  db.get().query "SELECT #{columns.join(',')} FROM users #{orderString};", (err, rows) ->
    if err
      return done err
    done null, rows

exports.getColumnsForPID = (columns, pid, done) ->
  db.get().query "SELECT #{columns.join(',')} FROM users WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows[0]

exports.getByUserPID = (pid, done) ->
  db.get().query "SELECT * FROM users WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows[0]

exports.getByUserName = (name, done) ->
  db.get().query "SELECT * FROM users WHERE BINARY user_name = \"#{name}\"", (err, rows) ->
    if err
      return done err
    done null, rows[0]

exports.isNameInUse = (name, done) ->
  db.get().query "SELECT * FROM users WHERE user_name = \"#{name}\"", (err, rows) ->
    if err
      return done err
    done null, rows[0]

exports.getByUserEmail = (email, done) ->
  db.get().query "SELECT * FROM users WHERE user_email = \"#{email}\";", (err, rows) ->
    if err
      return done err
    done null, rows[0]

exports.setName = (pid, username, done) ->
  validator.validateUsername(username)
  db.get().query "UPDATE users SET user_name = \"#{username}\" WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

exports.setEmail = (pid, email, done) ->
  if validator.validateEmail(email)
    db.get().query "UPDATE users SET user_email = \"#{email}\" WHERE user_pid = \"#{pid}\";", (err, rows) ->
      if err
        return done err
      done null, rows

exports.setPassword = (pid, password, done) ->
  if validator.validatePassword(password)
    password = bcrypt.hashSync(password)
    db.get().query "UPDATE users SET user_password_hash = \"#{password}\" WHERE user_pid = \"#{pid}\";", (err, rows) ->
      if err
        return done err
      done null, rows

exports.setMC = (pid, mcName, done) ->
  db.get().query "UPDATE users SET user_mccharacter = \"#{mcName}\" WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

exports.setPoints = (pid, amount, done) ->
  db.get().query "UPDATE users SET user_points = #{amount} WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

exports.addPoints = (pid, amount, done) ->
  db.get().query "UPDATE users SET user_points = user_points + #{amount} WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

exports.removePoints = (pid, amount, done) ->
  db.get().query "UPDATE users SET user_points = user_points - #{amount} WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

exports.toggleAdmin = (pid, done) ->
  db.get().query "UPDATE users SET user_isadmin = IF(user_isadmin=1, 0, 1) WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    exports.getColumnsForPID ['user_isadmin'], pid, (err, result) ->
      if err
        return done err
      done null, result[0]['user_isadmin']

exports.toggleStaff = (pid, done) ->
  db.get().query "UPDATE users SET user_isstaff = IF(user_isstaff=1, 0, 1) WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    exports.getColumnsForPID ['user_isstaff'], pid, (err, result) ->
      if err
        return done err
      done null, result[0]['user_isstaff']

exports.deleteUser = (pid, done) ->
  db.get().query "DELETE FROM users WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

exports.countUsers = (done) ->
  db.get().query "SELECT COUNT(user_id) FROM users;", (err, rows) ->
    if err
      return done(err)
    done null, rows[0]['COUNT(user_id)']

exports.resetPassword = (email, done) ->
  newPassword = pidGen.generatePid()
  password = bcrypt.hashSync(newPassword)
  db.get().query "UPDATE users SET user_password_hash = \"#{password}\" WHERE user_email = \"#{email}\";", (err, rows) ->
    if err
      return done err
    done err, newPassword

exports.checkPassword = (username, password, done) ->
  db.get().query "SELECT user_pid, user_name, user_password_hash FROM users WHERE BINARY user_name = \"#{username}\" OR user_email = \"#{username}\";", (err, rows) ->
    if err
      return done "incorrect_login"
    if rows.length is 0
      return done "incorrect_login"
    passHash = rows[0]['user_password_hash']
    username = rows[0]['user_name']
    pid = rows[0]['user_pid']
    try
      if bcrypt.compareSync password, passHash
        return done "valid_login", pid, username
      else
        return done "incorrect_password"
    catch e
      return done "hash_check_error", null, null, e

exports.createToken = (user, done) ->
  db.get().query "DELETE FROM tokens WHERE user_name = \"#{user['user_name']}\" AND user_email = \"#{user['user_email']}\";", (err, rows) ->
    if not err
      token = pidGen.generatePid(32)
      values = [
        token
        user['user_name']
        user['user_email']
      ]
      db.get().query "INSERT INTO tokens (token, user_name, user_email) VALUES(?, ?, ?);", values, (err, rows) ->
        if err
          return done err
        else
          done null, token

exports.getToken = (token, done) ->
  db.get().query "SELECT * FROM tokens WHERE token = \"#{token}\"", (err, rows) ->
    if err
      return done err
    if rows[0]
      done null, rows[0]
    else
      done "token_invalid"

exports.deleteToken = (token, done) ->
  db.get().query "DELETE FROM tokens WHERE token = \"#{token}\"", (err, rows) ->
    if err
#      logger.error err
      done err
    else
      done null