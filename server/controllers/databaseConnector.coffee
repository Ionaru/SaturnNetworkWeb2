fs = require('fs')
mysql = require('mysql')

state =
  pool: null
  mode: null

exports.connect = (done, customConfig=null) ->
  if customConfig
    dbOptions = customConfig
  else
    dbOptions =
      host: dbConfig['db_host']
      user: dbConfig['db_user']
      password: dbConfig['db_pass']
      database: dbConfig['db_name']
      ssl:
        ca: fs.readFileSync('./config/crts/' + dbConfig['db_ca_f'])
        cert: fs.readFileSync('./config/crts/' + dbConfig['db_cc_f'])
        key: fs.readFileSync('./config/crts/' + dbConfig['db_ck_f'])
        rejectUnauthorized: false
  state.pool = mysql.createPool dbOptions
  done()
  return

exports.get = ->
  state.pool
