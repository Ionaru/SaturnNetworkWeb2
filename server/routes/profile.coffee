express = require('express')
router = express.Router()
User = require('../models/user')

router.get '/', (req, res) ->
  if req.session.user.login
    User.getColumnsForPID ['*'], req.session.user.pid, (err, result) ->
      if not err
        res.render 'profile', {profile: result}
      else
        res.render 'status/404'
  else
    res.render 'status/404'

router.get '/*', (req, res) ->
  user = req.url.slice(1)
  if req.session.user.login
    User.getByUserPID user, (err, result) ->
      if not err
        if result
          if (req.session.user.pid is result['user_pid']) or req.session.user.isAdmin
            res.render 'profile', {profile: result}
          else
            res.render 'status/404'
        else
          User.getByUserName user, (err, result) ->
            if not err
              if result
                if (req.session.user.pid is result['user_pid']) or req.session.user.isAdmin
                  res.render 'profile', {profile: result}
                else
                  res.render 'status/404'
              else
                User.getByUserEmail user, (err, result) ->
                  if not err
                    if result
                      if (req.session.user.pid is result['user_pid']) or req.session.user.isAdmin
                        res.render 'profile', {profile: result}
                      else
                        res.render 'status/404'
                    else
                      res.render 'status/404'
                  else
                    res.render 'status/404'
            else
              res.render 'status/404'
      else
        res.render 'status/404'
  else
    res.render 'status/404'

module.exports = router