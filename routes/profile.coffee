express = require('express')
router = express.Router()
multer = require('multer')
db = require('./../controllers/databaseConnector')
pidGen = require('./../controllers/pidGenerator')
fs = require('fs')

getProfileData = (callback, pid) ->
  data = new Array
  query = "SELECT profile_name,
                  profile_creator,
                  profile_createdate,
                  profile_updatedate,
                  profile_game,
                  profile_product,
                  profile_rating,
                  profile_ratings,
                  profile_downloads,
                  profile_link
          FROM profiles
          WHERE profile_pid = \"#{pid}\"
          LIMIT 1;"
  connection = db.connect()
  connection.connect()
  connection.query query, (err, rows, fields) ->
    if not err
      if rows.length
        data = rows[0]
        data.game_assigned = true
        data.product_assigned = true
        if not data.profile_game
          data.profile_game = "No game assigned yet"
          data.game_assigned = false
        if not data.profile_product
          data.profile_product = "No product assigned yet"
          data.product_assigned = false
        callback data
      else
        callback null
    connection.end()

router.get '/*', (req, res, next) ->
  if req.path.replace(/[/]+/g, '').toUpperCase() is "UPLOAD"
    if req.session.user
      res.render 'profile_upload'
    else
      res.render 'auth'
  else
    render = (data) ->
      if data
        res.render 'profile',
          profile_name: data.profile_name
          profile_creator: data.profile_creator
          profile_createdate: data.profile_createdate
          profile_updatedate: data.profile_updatedate
          profile_ratings: data.profile_ratings
          profile_rating: data.profile_rating
          profile_downloads: data.profile_downloads
          profile_product: data.profile_product
          profile_game: data.profile_game
          profile_gamelink: data.profile_game.replace(/\s+/g, '')
          profile_link: data.profile_link
          game_assigned: data.game_assigned
          product_assigned: data.product_assigned
      else
        res.render '404'
    getProfileData render, req.path.replace(/[/]+/g, '')

uploads = multer({
  dest: './tmp/'
})

generateUniquePid = (callback) ->
  connection = db.connect()
  connection.connect()
  pid = pidGen.generatePid(10)
  escPid = connection.escape(pid)
  pidQuery = "SELECT profile_pid FROM profiles WHERE profile_pid = #{escPid}"
  connection.query pidQuery, (err, rows, fields) ->
    connection.end()
    if rows.length is not 0
      generateUniquePid callback
    else
      callback pid

saveProfile = (profileData, callback) ->
  connection = db.connect()
  connection.connect()
  profile_pid = connection.escape(profileData.pid)
  profile_name = connection.escape(profileData.name)
  if profileData.product is "Other"
    profile_product = null
    profile_product_alt = connection.escape(profileData.product_other)
  else
    profile_product = connection.escape(profileData.product)
    profile_product_alt = null
  if profileData.game is "Other"
    profile_game = null
    profile_game_alt = connection.escape(profileData.game_other)
  else
    profile_game = connection.escape(profileData.game)
    profile_game_alt = null
  profile_link = connection.escape(profileData.link)
  profile_creator = connection.escape(profileData.creator)
  query = "INSERT INTO profiles (profile_pid,profile_name,profile_product,profile_product_alt,profile_game,profile_game_alt,profile_link,profile_creator)
          VALUES (#{profile_pid},#{profile_name},#{profile_product},#{profile_product_alt},#{profile_game},#{profile_game_alt},#{profile_link},#{profile_creator});"
  connection.query query, (err, rows, fields) ->
    if !err
      callback "success"
    else
      console.log err
      callback "failed"
  connection.end()

router.post '/upload', uploads.single('file'), (req, res, next) ->
  if req.session.user?.username
    name = req.body.name
    product = req.body.product
    product_other = req.body.product_other
    game = req.body.game
    game_other = req.body.game_other
    profileData = {
      name: name,
      product: product,
      product_other: product_other,
      game: game,
      game_other: game_other,
      creator: req.session.user.username
    }
    saveFile = (pid) ->
      profilePath = '/public/files/profiles/'
      downloadPath = '/files/profiles/'
      tempPath = projectDir + '/' + req.file.path
      savePath = projectDir + profilePath
      saveName = pid + '.xml'
      fs.createReadStream(tempPath).pipe(fs.createWriteStream(savePath + saveName))
      profileData.pid = pid
      profileData.link = req.headers.origin + downloadPath + saveName
      fs.unlinkSync(tempPath)
      redirect = (result) ->
        if result is "success"
          res.redirect req.headers.origin + '/profile/' + pid
        else
          fs.unlinkSync(savePath + saveName)
          res.send "Error"
      saveProfile profileData, redirect
    generateUniquePid saveFile
  else
    res.render 'auth'

module.exports = router