router = require('express').Router()
val = require('./../controllers/validationHelper')
User = require('../models/user')
jsesc = require('jsesc')
mail = require('../controllers/pidgeon')

# GLobal router for user info, permissions and cookies
router.get '/*', (req, res, next) ->
  if not req.session.user then req.session.user = {}
  # Refresh logged in user
  if req.session.user?.login
    pid = req.session.user.pid
    await User.getByUserPID(pid, defer(err, result))
    req.session.user = {
      pid: result['user_pid']
      username: result['user_name']
      email: result['user_email']
      points: result['user_points']
      isStaff: result['user_isstaff']
      isAdmin: result['user_isadmin']
      login: true
    }
    req.app.locals.user = req.session.user
    next()
  else
    req.session.user = {
      username: 'Guest'
      isStaff: 0
      isAdmin: 0
      login: false
    }
    req.app.locals.user = req.session.user
    return next()

# Router that handles the registration process
router.post '/register', (req, res) ->
  username = req.body.username
  email = req.body.email
  password = req.body.password
  if val.validateUsername(username) and val.validateEmail(email) and val.validatePassword(password)
    username = jsesc(username)
    email = jsesc(email)
    password = jsesc(password)
    await User.isNameInUse(username, defer(err, result))
    unless result
      await User.getByUserEmail(email, defer(err, result))
      unless result
        await User.create(username, email, password, defer(err, pid))
        if err
          return res.send(['other_error', null])
        else
          userResult = {
            pid: pid
            username: username
            email: email
            points: 0
            isStaff: 0
            isAdmin: 0
            login: true
          }
          req.app.locals.user = userResult
          req.session.user = userResult
          logger.info "New User created -> #{username}"
          return res.send(['account_created', userResult])
      else
        return res.send(['email_in_use', null])
    else
      return res.send(['username_in_use', null])
  else
    return res.send(['error_validation', null])

# Router that handles the login process
router.post '/login', (req, res) ->
  username = req.body.user
  password = req.body.password
  # cookietime = req.body.cookietime
  usernameValidated = val.validateUsername(username)
  emailValidated = val.validateEmail(username)
  passwordValidated = val.validatePassword(password)
  if (usernameValidated or emailValidated) and passwordValidated
    username = jsesc(username)
    password = jsesc(password)
    User.checkPassword username, password, (result, pid, name, e) ->
      switch result
        when 'valid_login'
          logger.info "User password validated -> #{name}"
          User.getByUserPID pid, (err, result_user) ->
            userResult = {
              pid: result_user['user_pid']
              username: result_user['user_name']
              email: result_user['user_email']
              points: result_user['user_points']
              isStaff: result_user['user_isstaff']
              isAdmin: result_user['user_isadmin']
              login: true
            }
            req.app.locals.user = userResult
            req.session.user = userResult
            return res.send([result, userResult])
        when 'incorrect_login'
          logger.warn("User login incorrect -> #{username}")
          return res.send([result, null])
        when 'incorrect_password'
          logger.warn("User password incorrect -> #{username}")
          return res.send([result, null])
        when 'hash_check_error'
          logger.error("Unable to validate password for User -> #{username}")
          logger.error("> #{e}")
          return res.send([result, null])
  else
    return res.send ['error_validation', null]

# Router that handles the password-change process
router.post '/change_password', (req, res) ->
  if req.session?.user?.login
    oldPass = req.body.old
    newPass = req.body.new
    userPid = req.session.user.pid
    username = req.session.user.username
    oldPassVal = val.validatePassword(oldPass)
    newPassVal = val.validatePassword(newPass)
    if oldPassVal and newPassVal
      if oldPass isnt newPass
        oldPass = jsesc(oldPass)
        newPass = jsesc(newPass)
        username = jsesc(username)
        User.checkPassword username, oldPass, (result, pid, name, e) ->
          switch result
            when 'valid_login'
              if pid is userPid and name is username
                await User.setPassword(pid, newPass, defer(err))
                if not err
                  return res.send('password_changed')
                else
                  return res.send('password_set_fail')
            when 'incorrect_login'
              return res.send('user_get_fail')
            when 'incorrect_password'
              return res.send(result)
            when 'hash_check_error'
              logger.error("Unable to validate password for User -> #{username}")
              logger.error("> #{e}")
              return res.send(result)
      else
        return res.send('same_password')
    else
      return res.send('error_validation')
  else
    return res.render('auth')


# Router that handles the logout process
router.all '/logout', (req, res) ->
  # Destroy the user session
  req.session.destroy ->
    # Redirect the user back to the homepage, in case they were on a page with sensitive information
    return res.redirect('/')
  return

# Router that handles the password-reset process
router.post '/reset', (req, res) ->
  email = req.body.email
  emailValidated = val.validateEmail(email)
  if emailValidated
    await User.getByUserEmail(email, defer(err, result))
    if not err
      if result
        await User.createToken(result, defer(err, token))
        if not err
          await mail.sendResetPassword(result, token, defer(err))
          if not err
            return res.send(['password_reset', User])
          else
            return res.send(['error_mail', null])
        else
          return res.send(['token_error', null])
      else
        return res.send(['incorrect_email', null])
    else
      return res.send(['error_user', null])
  else
    return res.send(['error_validation', null])

# TODO: IMPLEMENT
# Router that handles the cookie notification
#router.post '/accept_cookies', (req, res) ->
# req.session.accept_cookies = true
# res.send "cookies_accepted"

module.exports = router
