express = require 'express'
router = express.Router()
User = require '../models/user'

router.get '/', (req, res) ->
  if req.session.user.login
    User.getColumns ['*'], 'user_name', (err, result) ->
      if not err
        res.render 'user_management', {users: result}
        logger.info "[#{req.session.user.username}] loaded user management"

router.get '/*', (req, res) ->
  User.getColumns ['*'], 'user_name', (err, result) ->
    if not err
      res.render 'user_management', {users: result}
      logger.info "Admin loaded user management -> " + req.session.user.username