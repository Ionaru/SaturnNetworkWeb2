express = require('express')
router = express.Router()
multer = require('multer')
db = require('./../controllers/databaseConnector')

getUnlistedProfiles = (callback) ->
  unlisted = new Array
  query = "SELECT * FROM profiles WHERE profile_state = \"proposed\" OR profile_state = \"unlisted\"";
  connection = db.connect()
  connection.connect()
  connection.query query, (err, rows, fields) ->
    connection.end()
    if not err
      if rows
        callback rows
    else
      callback "error"

getListedProfiles = (callback) ->
  unlisted = new Array
  query = "SELECT * FROM profiles WHERE profile_state = \"listed\"";
  connection = db.connect()
  connection.connect()
  connection.query query, (err, rows, fields) ->
    connection.end()
    if not err
      if rows
        callback rows
    else
      callback "error"

DeleteProfile = (callback, profilePID) ->
  query = "UPDATE profiles SET profile_state = \"unlisted\" WHERE profile_pid = \"#{profilePID}\"";
  connection = db.connect()
  connection.connect()
  connection.query query, (err, rows, fields) ->
    connection.end()
    if not err
      callback "success"
    else
      callback "error"

ListProfile = (callback, profilePID) ->
  query = "UPDATE profiles SET profile_state = \"listed\" WHERE profile_pid = \"#{profilePID}\"";
  connection = db.connect()
  connection.connect()
  connection.query query, (err, rows, fields) ->
    connection.end()
    if not err
      callback "success"
    else
      callback "error"

UnlistProfile = (callback, profilePID) ->
  query = "UPDATE profiles SET profile_state = \"proposed\" WHERE profile_pid = \"#{profilePID}\"";
  connection = db.connect()
  connection.connect()
  connection.query query, (err, rows, fields) ->
    connection.end()
    if not err
      callback "success"
    else
      callback "error"

EditProfile = (callback, profileData) ->
  query = "UPDATE profiles SET profile_name = \"#{profileData.name}\", profile_product = \"#{profileData.product}\", profile_game = \"#{profileData.game}\", WHERE profile_pid = \"#{profileData.pid}\"";
  connection = db.connect()
  connection.connect()
  connection.query query, (err, rows, fields) ->
    connection.end()
    if not err
      callback "success"
    else
      callback "error"

router.all '*', (req, res, next) ->
  if req.session.user?.perm >= 3
    next()
  else
    res.send "Permission Denied"

router.get '/', (req, res, next) ->
  getMore = (unlisted) ->
    render = (listed) ->
      res.render 'profile_management',
        unlisted: unlisted
        listed: listed
    getListedProfiles render
  getUnlistedProfiles getMore

uploads = multer({
  dest: './tmp/'
})

router.post '/delete_profile', (req, res, next) ->
  respond = (result) ->
    res.send result
  DeleteProfile respond, req.body.profilePID

router.post '/approve_profile', (req, res, next) ->
  respond = (result) ->
    res.send result
  ListProfile respond, req.body.profilePID

router.post '/unlist_profile', (req, res, next) ->
  respond = (result) ->
    res.send result
  UnlistProfile respond, req.body.profilePID

router.post '/edit_profile', (req, res, next) ->
  respond = (result) ->
    res.send result
  EditProfile respond, req.body.profilePID

module.exports = router