assert = require('assert')
request = require('supertest')
db = require('../../controllers/databaseConnector')
bcrypt = require('bcrypt-nodejs')

describe 'Prologue', ->
  describe 'First test, ensure Mocha is working.', ->
    it 'should complete this regular test', ->
      assert.ok(true)
    it 'should complete this test with a callback', (done) ->
      assert.ok(true)
      done()
    it 'should complete this test with a promise', ->
      new Promise (resolve) ->
        assert.ok(true)
        resolve()
  describe 'Start server', ->
    process.env['TESTMODE'] = true
    process.env['SILENT'] = true
    process.env['PORT'] = 3001
    require('../../bin/www')

describe 'Database', ->
  describe 'Create connection to test database', ->
    it 'should be able to get the current db session', (done) ->
      assert.notEqual(db.get(), null)
      done()
    it 'should be able to clear the test database', (done) ->
      await db.get().query("TRUNCATE TABLE `users`;", defer(err, rows))
      if err then throw err else done()

#TODO: More tests
describe 'User', ->
  User = require '../../models/user'
  testUserPid = null
  testUserName = "BILL_CIPHER"
  testUserEmail = "weirdmageddon@gravityfalls.com"
  testUserPassword = "BillCipher12345"
  describe 'Create', ->
    it 'can\'t use special characters in username'
    it 'can\'t use special characters in password'
    it 'can\'t use special characters in email'
    it 'can\'t create User with invalid username'
    it 'can\'t create User with invalid password'
    it 'can\'t create User with invalid email'
    it 'can\'t create User with too short username'
    it 'can\'t create User with too long username'
    it 'can\'t create User with too short email'
    it 'can\'t create User with too long email'
    it 'can\'t create User with too short password'
    it 'can\'t create User with too long password'

    it 'can create a User without error', (done) ->
      await User.create(testUserName, testUserEmail, testUserPassword, defer(err, result))
      assert.equal(err, null)
      testUserPid = result
      done()
    it 'can find newly created User by PID', (done) ->
      await User.getByUserPID(testUserPid, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_name'], testUserName)
      assert.equal(result['user_email'], testUserEmail)
      done()
    it 'can find newly created User by Name', (done) ->
      await User.getByUserName(testUserName, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_pid'], testUserPid)
      assert.equal(result['user_email'], testUserEmail)
      done()
    it 'can find newly created User by Email', (done) ->
      await User.getByUserEmail(testUserEmail, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_pid'], testUserPid)
      assert.equal(result['user_name'], testUserName)
      done()
    it 'can\'t create a User with the same name', (done) ->
      await User.create(testUserName, "2" + testUserEmail, testUserPassword, defer(err, result))
      assert.equal(err.code, "ER_DUP_ENTRY")
      done()
    it 'can\'t create a User with the same email', (done) ->
      await User.create(testUserName + "2", testUserEmail, testUserPassword, defer(err, result))
      assert.equal(err.code, "ER_DUP_ENTRY")
      done()

    testUser = {
      username: "User123",
      email: "mailmail@mail.com",
      password: "passwordddddddddd5"
    }
    request = request('http://localhost:3001');
    it 'can create a User through a request', ->
      request.post('/register').send(testUser).expect((res, err) ->
        assert.equal(res.body[0], 'account_created')
      )

  describe 'Modify', ->
    testUserNameNew = "BILLCIPHER5000"
    testUserEmailNew = "bill@gnomesrule.com"
    testUserPasswordNew = "99Password99"
    it 'can change a username', (done) ->
      await User.setName(testUserPid, testUserNameNew, defer(err, result))
      assert.equal(err, null)
      await User.getByUserPID(testUserPid, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_pid'], testUserPid)
      assert.equal(result['user_name'], testUserNameNew)
      assert.equal(result['user_email'], testUserEmail)
      await User.getByUserName(testUserNameNew, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_pid'], testUserPid)
      assert.equal(result['user_name'], testUserNameNew)
      assert.equal(result['user_email'], testUserEmail)
      done()
    it 'can change an email address', (done) ->
      await User.setEmail(testUserPid, testUserEmailNew, defer(err, result))
      assert.equal(err, null)
      await User.getByUserPID(testUserPid, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_pid'], testUserPid)
      assert.equal(result['user_name'], testUserNameNew)
      assert.equal(result['user_email'], testUserEmailNew)
      await User.getByUserName(testUserNameNew, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_pid'], testUserPid)
      assert.equal(result['user_name'], testUserNameNew)
      assert.equal(result['user_email'], testUserEmailNew)
      done()
    it 'can change a password', (done) ->
      await User.setPassword(testUserPid, testUserPasswordNew, defer(err, result))
      assert.equal(err, null)
      await User.getByUserPID(testUserPid, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_pid'], testUserPid)
      assert.equal(true, bcrypt.compareSync(testUserPasswordNew, result['user_password_hash']))
      done()
    after ->
      await User.setName(testUserPid, testUserName, defer(err, result))
      await User.setEmail(testUserPid, testUserEmail, defer(err, result))
      await User.setPassword(testUserPid, testUserPassword, defer(err, result))

  describe 'Delete', ->
    it 'can delete a non-existing User, but it will affect nothing', (done) ->
      await User.deleteUser("AAA12345BB", defer(err, result))
      assert.equal(err, null)
      assert.equal(result.affectedRows, 0)
      done()
    it 'can delete a User without error', (done) ->
      await User.deleteUser(testUserPid, defer(err, result))
      assert.equal(err, null)
      done()
    it 'deleted User should no longer exist', (done) ->
      await User.getByUserPID(testUserPid, defer(err, result))
      assert.equal(err, null)
      assert.equal(result, undefined)
      done()

#TODO: Test for other things
