express = require('express')
router = express.Router()
#User = require('../models/user')
val = require('./../controllers/validationHelper')
#keeper = require('./../controllers/gateKeeper')
pidGen = require '../controllers/pidGenerator'
bcrypt = require('bcrypt-nodejs')
user = require('../models/user')
jsesc = require('jsesc')

# Router for user info, permissions and cookies
router.get '/*', (req, res, next) ->
  if not req.session.user then req.session.user = {}
  # Refresh logged in user
  if req.session.user?.login
    pid = req.session.user.pid
    user.getByUserPID pid, (err, result) ->
      req.session.user =
        pid: result['user_pid']
        username: result['user_name']
        email: result['user_email']
        points: result['user_points']
        isStaff: result['user_isstaff']
        isAdmin: result['user_isadmin']
        login: true
      req.app.locals.user = req.session.user
      next()
  else
    req.session.user =
      username: 'Guest'
      isStaff: 0
      isAdmin: 0
      login: false
    req.app.locals.user = req.session.user
    next()

# Router that handles the registration process
router.post '/register', (req, res) ->
  username = req.body.username
  email = req.body.email
  password = req.body.password
  if val.validateUsername(username) and val.validateEmail(email) and val.validatePassword(password)
    username = jsesc username
    email = jsesc email
    password = jsesc password
    user.getByUserName username, (err, result) ->
      unless result
        user.getByUserEmail email, (err, result) ->
          unless result
            user.create username, email, password, (err, pid) ->
              if err
                res.send ['other_error', null]
              else
                userResult =
                  pid: pid
                  username: username
                  email: email
                  points: 0
                  isStaff: 0
                  isAdmin: 0
                  login: true
                req.app.locals.user = userResult
                req.session.user = userResult
                logger.info "New user created -> #{username}"
                res.send ['account_created', userResult]
          else
            res.send ['email_in_use', null]
      else
        res.send ['username_in_use', null]
  else
    res.send ['error_validation', null]

# Router that handles the login process
router.post '/login', (req, res) ->
  username = req.body.user
  password = req.body.password
  cookietime = req.body.cookietime
  usernameValidated = val.validateUsername username
  emailValidated = val.validateEmail username
  passwordValidated = val.validatePassword password

  if (usernameValidated or emailValidated) and passwordValidated
    username = jsesc username
    password = jsesc password
    user.checkPassword username, password, (result, pid, name, e) ->
      switch result
        when "valid_login"
          logger.info "User password validated -> #{name}"
          user.getByUserPID pid, (err, result_user) ->
            userResult =
              pid: result_user['user_pid']
              username: result_user['user_name']
              email: result_user['user_email']
              points: result_user['user_points']
              isStaff: result_user['user_isstaff']
              isAdmin: result_user['user_isadmin']
              login: true
            req.app.locals.user = userResult
            req.session.user = userResult
            res.send [result, userResult]
          break
        when "incorrect_login"
          logger.warn "User login incorrect -> #{username}"
          res.send [result, null]
          break
        when "incorrect_password"
          logger.warn "User password incorrect -> #{username}"
          res.send [result, null]
          break
        when "hash_check_error"
          logger.error "Unable to validate password for user -> #{username}"
          logger.error "> #{e}"
          res.send [result, null]
          break
  else
    res.send ['error_validation', null]

# Router that handles the password-change process
router.post '/change_password', (req, res) ->
  if req.session?.user?.login
  #  res.send "complete"
    oldPass = req.body.old
    newPass = req.body.new
    userPid = req.session.user.pid
    username = req.session.user.username
    oldPassVal = val.validatePassword oldPass
    newPassVal = val.validatePassword newPass

    if oldPassVal and newPassVal
      if oldPass isnt newPass
        oldPass = jsesc oldPass
        newPass = jsesc newPass
        username = jsesc username
        user.checkPassword username, oldPass, (result, pid, name, e) ->
          switch result
            when "valid_login"
              if pid is userPid and name is username
                user.setPassword pid, newPass, (err, result) ->
                  if not err
                    res.send 'password_changed'
                  else
                    res.send 'password_set_fail'
              break
            when "incorrect_login"
              res.send 'user_get_fail'
              break
            when "incorrect_password"
              res.send result
              break
            when "hash_check_error"
              logger.error "Unable to validate password for user -> #{username}"
              logger.error "> #{e}"
              res.send result
              break
      else
        res.send 'same_password'
    else
      res.send 'error_validation'
  else
    res.render 'auth'


# Router that handles the logout process
router.all '/logout', (req, res) ->
  req.session.user =
      login: false
  req.app.locals.user = req.session.user
  res.set('Cache-Control', 'no-cache');
  res.redirect "/"

# Router that handles the logout process
router.post '/reset', (req, res) ->
#  res.send ['error_validation', user]
  email = req.body.email
  emailValidated = val.validateEmail email
  if emailValidated
    user.getByUserEmail email, (err, result) ->
      if not err
        if result
          user.createToken result, (err, token) ->
            if not err
              mail = require '../controllers/pidgeon'
              mail.sendResetPassword result, token, (err) ->
                if not err
                  res.send ['password_reset', user]
                else
                  res.send ['error_mail', null]
            else
              res.send ['token_error', null]
        else
          res.send ['incorrect_email', null]
      else
        res.send ['error_user', null]
  else
    res.send ['error_validation', null]

# Router that handles the cookie notification
router.post '/accept_cookies', (req, res) ->
  req.session.accept_cookies = true
  res.send "cookies_accepted"

module.exports = router