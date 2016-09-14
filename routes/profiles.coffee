express = require('express')
router = express.Router()
db = require('./../controllers/databaseConnector')

getProfileData = (callback, search_for) ->
  data = new Array
  query = "SELECT COUNT(*) FROM profiles #{search_for};"
  connection = db.connect()
  connection.connect()
  connection.query query, (err, rows, fields) ->
    data.count = 0
    data.toprating = new Array
    data.mostdownloads = new Array
    data.newest = new Array
    if not err
      if rows.length
        data.count = rows[0]['COUNT(*)']
    query2 = "SELECT profile_pid, profile_name, profile_createdate, profile_game, profile_rating, profile_downloads, profile_product FROM profiles
              #{search_for} AND profile_state = \"listed\"
              ORDER BY profile_rating DESC
              LIMIT 10;"
    connection.query query2, (err, rows, fields) ->
      if not err
        for row in rows
          row.profile_gamelink = row.profile_game.replace(/\s+/g, '')
          data.toprating.push row
      query3 = "SELECT profile_pid, profile_name, profile_createdate, profile_game, profile_rating, profile_downloads, profile_product FROM profiles
                #{search_for} AND profile_state = \"listed\"
                ORDER BY profile_downloads DESC
                LIMIT 10;"
      connection.query query3, (err, rows, fields) ->
        if not err
          for row in rows
            row.profile_gamelink = row.profile_game.replace(/\s+/g, '')
            data.mostdownloads.push row
        query4 = "SELECT profile_pid, profile_name, profile_createdate, profile_game, profile_rating, profile_downloads, profile_product FROM profiles
                #{search_for} AND profile_state = \"listed\"
                ORDER BY profile_createdate
                LIMIT 10;"
        connection.query query4, (err, rows, fields) ->
          if not err
            for row in rows
              row.profile_gamelink = row.profile_game.replace(/\s+/g, '')
              data.newest.push row
            callback data
          connection.end()

router.get '/*', (req, res, next) ->
  getGame = (games) ->
    return games.urlname.toUpperCase() is req.path.replace(/[/]+/g, '').toUpperCase()
  getProduct = (products) ->
    return products.gcode.toUpperCase() is req.path.replace(/[/]+/g, '').toUpperCase()
  game = req.app.locals.games.find(getGame)
  product = req.app.locals.products.find(getProduct)
  if game
    render = (data) ->
      res.render 'profiles_game',
        game_name: game.name
        game_linkname: game.name.replace(/\s+/g, '')
        game_desc: game.shortdesc
        profile_count: data.count
        profile_single: data.count is 1
        profile_profiles: data.count > 0
        profiles_toprated: data.toprating
        profiles_mostdownloads: data.mostdownloads
        profiles_newest: data.newest
    getProfileData render, "WHERE profile_game = \"#{game.name}\" AND profile_state = \"listed\""
  else if product
    render = (data) ->
      res.render 'profiles_product',
        product_gcode: product.gcode
        product_fullname: product.fullname
        product_desc: product.shortdesc
        product_type: product.type
        profile_count: data.count
        profile_single: data.count is 1
        profile_profiles: data.count > 0
        profiles_toprated: data.toprating
        profiles_mostdownloads: data.mostdownloads
        profiles_newest: data.newest
    getProfileData render, "WHERE profile_product = \"#{product.gcode}\" AND profile_state = \"listed\""
  else
    render = (data) ->
      res.render 'profiles',
        profile_count: data.count
        profile_single: data.count is 1
        profile_profiles: data.count > 0
        profiles_toprated: data.toprating
        profiles_mostdownloads: data.mostdownloads
        profiles_newest: data.newest
    getProfileData render, "WHERE profile_state = \"listed\""
  
module.exports = router