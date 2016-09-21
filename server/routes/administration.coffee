express = require('express')
router = express.Router()
User = require '../models/user'
Validator = require '../controllers/validationHelper'
Jsesc = require('jsesc')


router.get '/users', (req, res) ->
  if req.session.user.login and req.session.user.isAdmin is 1
    User.getColumns ['*'], 'user_name', (err, result) ->
      if not err
        res.render 'user_management', {users: result}
  else
    res.render '404'

router.post '/users/update_name', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  newName = req.body.value
  if Validator.validateUsername newName
    newName = Jsesc newName
    User.getByUserName newName, (err, result) ->
      if not err
        if not result
          User.setName pid, newName, (err, result) ->
            if not err
              res.send newName
            else
              User.getByUserPID pid, (err, result) ->
                if not err
                  res.send result['user_name']
        else
          res.send result['user_name']
  else
    User.getByUserPID pid, (err, result) ->
      if not err
        res.send result['user_name']
  return

router.post '/users/update_email', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  newEmail = req.body.value
  if Validator.validateEmail newEmail
    newEmail = Jsesc newEmail
    User.getByUserEmail newEmail, (err, result) ->
      if not err
        if not result
          User.setEmail pid, newEmail, (err, result) ->
            if not err
              res.send newEmail
            else
              User.getByUserPID pid, (err, result) ->
                if not err
                  res.send result['user_email']
        else
          res.send result['user_email']
  else
    User.getByUserPID pid, (err, result) ->
      if not err
        res.send result['user_email']
  return

router.post '/users/update_minecraft_name', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  mcName = req.body.value
  if Validator.validateMinecraft mcName
    mcName = Jsesc mcName
    User.setMC pid, mcName, (err, result) ->
      if not err
        res.send mcName
      else
        User.getByUserPID pid, (err, result) ->
          if not err
            res.send result['user_mccharacter']
  else
    User.getByUserPID pid, (err, result) ->
      if not err
        res.send result['user_mccharacter']
  return

router.post '/users/update_points', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  newPoints = req.body.value
  if Validator.validatePoints newPoints
    newPoints = Jsesc newPoints
    User.setPoints pid, newPoints, (err, result) ->
      if not err
        res.send newPoints.toString()
      else
        User.getByUserPID pid, (err, result) ->
          if not err
            res.send result['user_points'].toString()
  else
    User.getByUserPID pid, (err, result) ->
      if not err
        res.send result['user_points'].toString()
  return
#router.put '/users/update_staff_status', (req, res) ->
#router.put '/users/update_admin_status', (req, res) ->
#router.delete '/users/delete_user', (req, res) ->

module.exports = router
