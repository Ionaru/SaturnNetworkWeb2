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
                res.send ['account_created', userResult]
          else
            res.send ['email_in_use', null]
      else
        res.send ['username_in_use', null]
  else
    res.send ['error_validation', null]

# Router that handles the login process
router.post '/login', (req, res) ->
#  res.send "complete"
  username = req.body.user
  password = req.body.password
  cookietime = req.body.cookietime
  usernameValidated = val.validateUsername username
  emailValidated = val.validateEmail username
  passwordValidated = val.validatePassword password

  if (usernameValidated or emailValidated) and passwordValidated
    username = jsesc username
    password = jsesc password
    user.checkPassword username, password, (result, pid) ->
      switch result
        when "valid_login"
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
          res.send [result, null]
          break
        when "incorrect_password"
          res.send [result, null]
          break
        when "hash_check_error"
          res.send [result, null]
          break
  else
    res.send ['error_validation', null]

# Router that handles the logout process
router.all '/logout', (req, res) ->
  req.session.user =
      login: false
  req.app.locals.user = req.session.user
  res.redirect "/"

# Router that handles the cookie notification
router.post '/accept_cookies', (req, res) ->
  req.session.accept_cookies = true
  res.send "cookies_accepted"

module.exports = router