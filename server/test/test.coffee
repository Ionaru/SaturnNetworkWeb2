assert = require 'assert'
describe 'Prologue', ->
  describe 'First test, ensure Mocha is working.', ->
    it 'should complete this regular test', ->
      assert.ok true
    it 'should complete this test with a promise', ->
      new Promise (resolve) ->
        assert.ok true
        resolve()

#TODO: Database rollbacks
describe 'Database', ->
  db = require '../controllers/databaseConnector'
  describe 'Create connection to test database', ->
    it 'should connect without issue', (done) ->
      fs = require 'fs'
      ini = require('ini')
      dbConfig = ini.parse fs.readFileSync("./config/database.ini", "utf-8")
      dbOptions =
        host: dbConfig['db_host']
        user: dbConfig['db_user']
        password: dbConfig['db_pass']
        database: dbConfig['db_name'] + "_test"
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
    it 'should be able to get the current db session', ->
      assert.notEqual(db.get(), null)

#TODO: More tests
describe 'User', ->
  user = require '../models/user'
  testUserPid = null
  testUserName = "BILL_CIPHER"
  testUserEmail = "bill_cipher@weirdmageddon.com"
  testUserPassword = "BillCipher12345"
  describe 'Create', ->
    it 'can create a user without error', (done) ->
      user.create testUserName, testUserEmail, testUserPassword, (err, result) ->
        assert.equal(err, null)
        if not err
          testUserPid = result
        done()
    it 'can find newly created user by PID', (done) ->
      user.getByUserPID testUserPid, (err, result) ->
        assert.equal(err, null)
        if not err
          assert.equal(result['user_name'], testUserName)
          assert.equal(result['user_email'], testUserEmail)
        done()
    it 'can find newly created user by Name', (done) ->
      user.getByUserName testUserName, (err, result) ->
        assert.equal(err, null)
        if not err
          assert.equal(result['user_pid'], testUserPid)
          assert.equal(result['user_email'], testUserEmail)
        done()
    it 'can find newly created user by Email', (done) ->
      user.getByUserEmail testUserEmail, (err, result) ->
        assert.equal(err, null)
        if not err
          assert.equal(result['user_pid'], testUserPid)
          assert.equal(result['user_name'], testUserName)
        done()

  describe 'Modify', ->
    describe 'Username', ->
      testUserNameNew = "BILLCIPHER5000"
      it 'can edit a username', (done) ->
        user.setName testUserPid, testUserNameNew, (err, result) ->
          assert.equal(err, null)
          done()
      it 'can verify edit by PID', (done) ->
        user.getByUserPID testUserPid, (err, result) ->
          assert.equal(err, null)
          if not err
            assert.equal(result['user_name'], testUserNameNew)
            assert.equal(result['user_email'], testUserEmail)
          done()
      it 'can verify edit by Name', (done) ->
        user.getByUserName testUserNameNew, (err, result) ->
          assert.equal(err, null)
          if not err
            assert.equal(result['user_pid'], testUserPid)
            assert.equal(result['user_email'], testUserEmail)
          done()
      it 'can revert the username', (done) ->
        user.setName testUserPid, testUserName, (err, result) ->
          assert.equal(err, null)
          done()

  describe 'Delete', ->
    it 'can delete a user without error', (done) ->
      user.deleteUser testUserPid, (err, result) ->
        assert.equal(err, null)
        done()
    it 'deleted user should no longer exist', (done) ->
      user.getByUserPID testUserPid, (err, result) ->
        assert.equal(err, null)
        assert.equal(result, undefined)
        done()

#TODO: Test for other things
