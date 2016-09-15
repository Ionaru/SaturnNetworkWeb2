assert = require 'assert'
describe 'Prologue', ->
  describe 'First test, ensure Mocha is working.', ->
    it 'assert.ok true', ->
      assert.ok true

#TODO: Database rollbacks
describe 'Database', ->
  db = require '../controllers/databaseConnector'
  describe 'Create connection to test database', ->
    it 'Should connect without issue', (done) ->
      fs = require 'fs'
      ini = require('ini')
      dbConfig = ini.parse fs.readFileSync("./config/database.ini", "utf-8")
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
      db.connect ((err) ->
        if err
          throw err
        else
          done()
      ), dbOptions
  describe 'Get DB session', ->
    console.log db.get()

#TODO: More tests
describe 'User', ->
  user = require '../models/user'
  testUserPid = null
  describe 'Create', ->
    it 'Can create a user without error', (done) ->
      user.create "BILL_CIPHER", "bill_cipher@weirdmageddon.com", "BillCipher12345", (err, result) ->
        if not err
          testUserPid = result
          done()

  describe 'Delete', ->
    it 'Can delete a user without error', (done) ->
      user.deleteUser testUserPid, (err, result) ->
        if not err then done()
    it 'Deleted user should no longer exist', (done) ->
      user.getByUserPID testUserPid, (err, result) ->
        if result is undefined
          done()

#TODO: Test for other things
