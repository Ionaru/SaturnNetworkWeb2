express = require 'express'
router = express.Router()
User = require '../models/user'
Validator = require '../controllers/validationHelper'
Jsesc = require('jsesc')

router.all '/*', (req, res, next) ->
  if req.session.user.login and req.session.user.isAdmin is 1
    logger.info "[#{req.session.user.username}] accessed Admin functions"
    next()
  else
    logger.warn "[#{req.session.user.username} (#{req['ip']})] tried to access Admin functions but was not authorised"
    res.render 'status/404'

router.get '/users', (req, res) ->
  User.getColumns ['*'], 'user_name', (err, result) ->
    if not err
      logger.info "[#{req.session.user.username}] loaded user management"
      res.render 'user_management', {users: result}

router.post '/users/update_name', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  User.getColumnsForPID ['user_name'], pid, (err, result) ->
    if not err
      oldName = result['user_name']
      newName = req.body.value
      if newName isnt oldName and Validator.validateUsername newName
        newName = Jsesc newName
        User.getByUserName newName, (err, result) ->
          if not err and not result
            User.setName pid, newName, (err) ->
              if not err
                logger.info "[#{req.session.user.username}] changed username of #{oldName} to #{newName}"
                res.send newName
              else
                res.send oldName
          else
            res.send oldName
      else
        res.send oldName
    else
      res.send "Error"
  return

router.post '/users/update_email', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  User.getColumnsForPID ['user_name', 'user_email'], pid, (err, result) ->
    if not err
      name = result['user_name']
      oldEmail = result['user_email']
      newEmail = req.body.value
      if oldEmail isnt newEmail and Validator.validateEmail newEmail
        newEmail = Jsesc newEmail
        User.getByUserEmail newEmail, (err, result) ->
          if not err and not result
            User.setEmail pid, newEmail, (err) ->
              if not err
                logger.info "[#{req.session.user.username}] changed email of #{name} from #{oldEmail} to #{newEmail}"
                res.send newEmail
              else
                res.send oldEmail
          else
            res.send oldEmail
      else
        res.send oldEmail
    else
      res.send "Error"
  return

router.post '/users/update_minecraft_name', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  User.getColumnsForPID ['user_name', 'user_mccharacter'], pid, (err, result) ->
    if not err
      name = result['user_name']
      oldName = result['user_mccharacter']
      newName = req.body.value
      if newName isnt oldName and Validator.validateMinecraft newName
        newName = Jsesc newName
        User.setMC pid, newName, (err) ->
          if not err
            logger.info "[#{req.session.user.username}] changed minecraft name of #{name} from #{oldName} to #{newName}"
            res.send newName
          else
            res.send oldName
      else
        res.send oldName
    else
      res.send "Error"
  return

router.post '/users/update_points', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  User.getColumnsForPID ['user_name', 'user_points'], pid, (err, result) ->
    if not err
      name = result['user_name']
      oldData = result['user_points'].toString()
      newData = req.body.value
      if Validator.validatePoints newData
        newData = Jsesc newData
        User.setPoints pid, newData, (err) ->
          if not err
            newData = newData.toString()
            logger.info "[#{req.session.user.username}] changed points balance of #{name} from #{oldData} to #{newData}"
            res.send newData
          else
            res.send oldData
      else
        res.send oldData
    else
      res.send "Error"
  return

router.post '/users/toggle_staff', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  User.getColumnsForPID ['user_name', 'user_isstaff'], pid, (err, result) ->
    if not err
      name = result['user_name']
      oldData = result['user_isstaff'].toString()
      User.toggleStaff pid, (err, result) ->
        if not err
          newData = result.toString()
          logger.info "[#{req.session.user.username}] changed admin status of #{name} from #{oldData} to #{newData}"
          res.send newData
        else
          res.send oldData
    else
      res.send "error"
  return

router.post '/users/toggle_admin', (req, res) ->
  pid = req.body.id.slice(req.body.id.indexOf('_') + 1)
  if req.session.user.pid isnt pid
    User.getColumnsForPID ['user_name', 'user_isadmin'], pid, (err, result) ->
      if not err
        name = result['user_name']
        oldData = result['user_isadmin'].toString()
        User.toggleAdmin pid, (err, result) ->
          if not err
            newData = result.toString()
            logger.info "[#{req.session.user.username}] changed staff status of #{name} from #{oldData} to #{newData}"
            res.send newData
          else
            res.send oldData
      else
        res.send "error"
  else
    res.send "1"
  return
#router.delete '/users/reset_password', (req, res) ->
#router.delete '/users/delete_user', (req, res) ->

module.exports = router
