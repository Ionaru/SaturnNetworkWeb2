router = require('express').Router()
User = require('../models/user')
val = require('./../controllers/validationHelper')
Jsesc = require('jsesc')

router.get '/*', (req, res) ->
  token = req.url.slice(1)
  if val.validateToken(token)
    token = Jsesc token
    User.getToken token, (err, user) ->
      if not err
        username = user['user_name']
        email = user['user_email']
        User.resetPassword email, (err, newpass) ->
          if not err
            await User.deleteToken(token, defer(err))
            if not err
              res.render('reset', {
                valid: true
                name: username
                new_pass: newpass
              })
            else
              res.render('reset', {valid: false})
          else
            res.render('reset', {valid: false})
      else
        res.render('reset', {valid: false})
  else
    res.render('reset', {valid: false})

module.exports = router
