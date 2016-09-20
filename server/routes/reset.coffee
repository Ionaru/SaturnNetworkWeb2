express = require('express')
router = express.Router()
User = require('..//models/User')
val = require('./../controllers/validationHelper')
jsesc = require('jsesc')

router.get '/*', (req, res) ->
  token = req.url.slice(1)
  if val.validateToken(token)
    token = jsesc token
    User.getToken token, (err, user) ->
      if not err
        username = user['user_name']
        email = user['user_email']
        User.resetPassword email, (err, newpass) ->
          if not err
            User.deleteToken token, (err) ->
              if not err
                res.render 'reset',
                  valid: true
                  name: username
                  new_pass: newpass
              else
                res.render 'reset',
                  valid: false
          else
            res.render 'reset',
              valid: false
      else
        res.render 'reset',
          valid: false
  else
    res.render 'reset',
      valid: false

module.exports = router