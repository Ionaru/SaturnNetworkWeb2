router = require('express').Router()
User = require('../models/user')

router.get '/', (req, res) ->
  if req.session.user.login
    await User.getColumnsForPID(['*'], req.session.user.pid, defer(err, result))
    if not err
      delete result['user_id']
      delete result['user_password_hash']
      return res.send(result)
    else
      return res.render('status/404')
  else
    return res.render('status/404')

router.get '/*', (req, res) ->
  user = req.url.slice(1)
  if req.session.user.login
    await User.getByUserPID(user, defer(err, result))
    if not err
      if result
        if (req.session.user.pid is result['user_pid']) or req.session.user.isAdmin
          delete result['user_id']
          delete result['user_password_hash']
          return res.send(result)
        else
          return res.render('status/404')
      else
        await User.getByUserName(user, defer(err, result))
        if not err
          if result
            if (req.session.user.pid is result['user_pid']) or req.session.user.isAdmin
              delete result['user_id']
              delete result['user_password_hash']
              return res.send(result)
            else
              return res.render('status/404')
          else
            await User.getByUserEmail(user, defer(err, result))
            if not err
              if result
                if (req.session.user.pid is result['user_pid']) or req.session.user.isAdmin
                  delete result['user_id']
                  delete result['user_password_hash']
                  return res.send(result)
                else
                  return res.render('status/404')
              else
                return res.render('status/404')
            else
              return res.render('status/404')
        else
          return res.render('status/404')
    else
      return res.render('status/404')
  else
    return res.render('status/404')

module.exports = router