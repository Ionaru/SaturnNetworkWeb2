express = require('express')
router = express.Router()
user = require '../models/user'


router.get '/users', (req, res) ->
  if req.session.user.login && req.session.user.isAdmin is 1
    user.getColumns ['*'], 'user_name', (err, result) ->
      if not err
        res.render 'user_management', {users: result}
  else
    res.render '404'

router.put '/users/update_name', (req, res) ->
  console.log req.body
#router.put '/users/update_email', (req, res) ->
#router.put '/users/update_minecraft_name', (req, res) ->
#router.put '/users/update_points', (req, res) ->
#router.put '/users/update_staff_status', (req, res) ->
#router.put '/users/update_admin_status', (req, res) ->
#router.delete '/users/delete_user', (req, res) ->

module.exports = router