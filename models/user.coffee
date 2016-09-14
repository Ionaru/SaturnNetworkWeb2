db = require '../controllers/databaseConnector'
pidGen = require '../controllers/pidGenerator'
validator = require '../controllers/validationHelper'
bcrypt = require 'bcrypt-nodejs'

exports.create = (username, email, password, done) ->
  pidGen.generateUniqueUserPid (err, pid) ->
# Validate input again, just to be on the safe side
    if validator.validateUsername(username) && validator.validatePassword(password) && validator.validateEmail(email)
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
        logger.info "New user created -> #{username}"
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
    done null, rows

exports.getByUserPID = (pid, done) ->
  db.get().query "SELECT * FROM users WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows[0]

exports.getByUserName = (name, done) ->
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
  db.get().query "UPDATE users SET user_name = \"#{username}\" WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

exports.setEmail = (pid, email, done) ->
  db.get().query "UPDATE users SET user_email = #{email} WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

exports.setPassword = (pid, password, done) ->
  db.get().query "UPDATE users SET user_password = \"#{password}\" WHERE user_pid = \"#{pid}\";", (err, rows) ->
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
    done null, rows

exports.toggleStaff = (pid, done) ->
  db.get().query "UPDATE users SET user_isstaff = IF(user_isstaff=1, 0, 1) WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done null, rows

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

exports.checkPassword = (password, pid, done) ->
  db.get().query "SELECT user_password_hash FROM users WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    if bcrypt.compareSync(password, rows[0]['user_password_hash'])
      return done true
    done false

exports.resetPassword = (pid, done) ->
  newPassword = pidGen.generatePid()
  db.get().query "UPDATE users SET user_password_hash = \"#{newPassword}\" WHERE user_pid = \"#{pid}\";", (err, rows) ->
    if err
      return done err
    done newPassword

exports.checkPassword = (username, password, done) ->
  db.get().query "SELECT user_pid, user_name, user_password_hash FROM users WHERE BINARY user_name = \"#{username}\" OR user_email = \"#{username}\";", (err, rows) ->
    if err
      return done "incorrect_login", null
    if rows.length is 0
      logger.warn "User login incorrect -> #{username}"
      return done "incorrect_login", null
    passHash = rows[0]['user_password_hash']
    username = rows[0]['user_name']
    pid = rows[0]['user_pid']
    try
      if bcrypt.compareSync password, passHash
        logger.info "User password validated -> #{username}"
        return done "valid_login", pid
      else
        logger.warn "User password incorrect -> #{username}"
        return done "incorrect_password", null
    catch e
      logger.error "Unable to validate password for user -> #{username}"
      logger.error "> #{e}"
      return done "hash_check_error", null
