express = require('express')
router = express.Router()
user = require('..//models/user')
val = require('./../controllers/validationHelper')
jsesc = require('jsesc')

router.get '/*', (req, res) ->
  token = req.url.slice(1)
  if val.validateToken(token)
    token = jsesc token
    user.getToken token, (err, user) ->
      if not err
        username = user['user_name']
        email = user['user_email']
        user.resetPassword email, (err, newpass)->
          if not err
            res.render 'reset',
              valid: true
              name: username
              new_pass: newpass
      else
        res.render 'reset',
          valid: false

module.exports = router