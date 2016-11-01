assert = require('assert')
request = require('supertest')
db = require('../../controllers/databaseConnector')
bcrypt = require('bcrypt-nodejs')
request = request('http://localhost:3001')

db_suffix = '_test'

# coffeelint: disable=no_implicit_returns

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

    it 'should start the application', ->
      this.timeout(5000)
      process.env['TESTMODE'] = process.env['SILENT'] = true
      process.env['PORT'] = 3001
      require('../../bin/www')

describe 'Preparing the Database', ->

  describe 'Create connection to test database', ->

    it 'should be able to get the current db session', (done) ->
      assert.notEqual(db.get(), null)
      done()

    it "should be connected to a test database (ending with \"#{db_suffix}\")", (done) ->
      db.get().query 'SELECT DATABASE()', (err, rows) ->
        result = rows[0]['DATABASE()']
        assert.equal(err, null)
        re = new RegExp("#{db_suffix}$")
        assert.ok(re.test(result))
        if not re.test(result)
          process.exit(1)
        else
          done()

    it 'should be able to clear the \'users\' table in the test database', (done) ->
      await db.get().query('TRUNCATE TABLE `users`;', defer(err, rows))
      assert.equal(err, null)
      done()

    it 'should be able to clear the \'tokens\' table in the test database', (done) ->
      await db.get().query('TRUNCATE TABLE `tokens`;', defer(err, rows))
      assert.equal(err, null)
      done()

    it 'should be able to clear the \'sessions\' table in the test database', (done) ->
      await db.get().query('TRUNCATE TABLE `sessions`;', defer(err, rows))
      assert.equal(err, null)
      done()

#TODO: More tests
describe 'User interactions', ->

  User = require '../../models/user'
  testUserPid = null
  testUserName = 'BILL_CIPHER'
  testUserEmail = 'weirdmageddon@gravityfalls.com'
  testUserPassword = 'Bill93'

  describe 'Create a User', ->

    it 'can\'t use special characters in username', ->
      request.post('/register')
      .send({username: 'MyInval|d_name', email: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'error_validation')
      )

    it 'can\'t use special characters in email', ->
      request.post('/register')
      .send({username: testUserName, email: 'ma()il@mail.com', password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'error_validation')
      )

    it 'can\'t use special characters in password', ->
      request.post('/register')
      .send({username: testUserName, email: testUserEmail, password: 'MyInva/ilPassword'})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'error_validation')
      )

    it 'can\'t create User with too short username', ->
      request.post('/register')
      .send({username: 'Bo', email: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'error_validation')
      )

    it 'can\'t create User with too long username', ->
      request.post('/register')
      .send({username: 'ThisUSernameIsWayTooLongForTheSystem', email: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'error_validation')
      )

    it 'can\'t create User with too short email', ->
      request.post('/register')
      .send({username: testUserName, email: 'm@m.c', password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'error_validation')
      )

    it 'can\'t create User with too short password', ->
      request.post('/register')
      .send({username: testUserName, email: testUserEmail, password: 'Passw'})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'error_validation')
      )

    it 'can create a User without error', ->
      request.post('/register')
      .send({username: testUserName, email: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        user = res.body[1]
        assert.equal(message, 'account_created')
        assert.equal(user['username'], testUserName)
        assert.equal(user['email'], testUserEmail)
        assert.equal(user['points'], 0)
        assert.equal(user['isStaff'], 0)
        assert.equal(user['isAdmin'], 0)
        assert.equal(user['login'], true)
        testUserPid = user['pid']
      )

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

    it 'can find newly created User by PID', (done) ->
      await User.getByUserPID(testUserPid, defer(err, result))
      assert.equal(err, null)
      assert.equal(result['user_name'], testUserName)
      assert.equal(result['user_email'], testUserEmail)
      done()

    it 'can\'t create a User with the same name', ->
      request.post('/register')
      .send({username: testUserName, email: testUserEmail + 'm', password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'username_in_use')
      )

    it 'can\'t create a User with the same email', ->
      request.post('/register')
      .send({username: testUserName + '2', email: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'email_in_use')
      )

  describe 'User login', ->
    it 'can login with valid credentials (username)', ->
      request.post('/login')
      .send({user: testUserName, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'valid_login')
      )
    it 'can login with valid credentials (email)', ->
      request.post('/login')
      .send({user: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'valid_login')
      )
    it 'can\'t login with incorrect password', ->
      request.post('/login')
      .send({user: testUserName, password: 'Bogopass123'})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'incorrect_password')
      )
    it 'can\'t login with non-existing username', ->
      request.post('/login')
      .send({user: 'Bogoname', password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'incorrect_login')
      )
  describe 'User profile', ->
    it 'can fetch its own profile by name', ->
      request.post('/login')
      .send({user: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'valid_login')
        request.get("/profile/#{testUserName}")
        .expect((res) ->
          message = res.body[0]
          assert.equal(message['user_pid'], testUserPid)
          assert.equal(message['user_name'], testUserName)
          assert.equal(message['user_email'], testUserEmail)
        )
      )
    it 'can fetch its own profile by email', ->
      request.post('/login')
      .send({user: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'valid_login')
        request.get("/profile/#{testUserEmail}")
        .expect((res) ->
          message = res.body[0]
          assert.equal(message['user_pid'], testUserPid)
          assert.equal(message['user_name'], testUserName)
          assert.equal(message['user_email'], testUserEmail)
        )
      )
    it 'can fetch its own profile by PID', ->
      request.post('/login')
      .send({user: testUserEmail, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'valid_login')
        request.get("/profile/#{testUserPid}")
        .expect((res) ->
          message = res.body[0]
          assert.equal(message['user_pid'], testUserPid)
          assert.equal(message['user_name'], testUserName)
          assert.equal(message['user_email'], testUserEmail)
        )
      )

  describe 'Modify the User', ->
    testUserNameNew = 'BILLCIPHER5000'
    testUserEmailNew = 'bill@gnomesrule.com'
    testUserPasswordNew = '99Password99'

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

    it 'can change a password', ->
      request.post('/login')
      .send({user: testUserNameNew, password: testUserPassword})
      .expect((res) ->
        message = res.body[0]
        assert.equal(message, 'valid_login')
        request.post('/change_password')
        .send({old: testUserPassword, new: testUserPasswordNew})
        .expect((res) ->
          message = res.body[0]
          assert.equal(message, 'password_changed')
        )
      )

    after ->
      await User.setName(testUserPid, testUserName, defer(err, result))
      await User.setEmail(testUserPid, testUserEmail, defer(err, result))
      await User.setPassword(testUserPid, testUserPassword, defer(err, result))

  describe 'Delete the User', ->

    it 'can delete a non-existing User, but it will affect nothing', (done) ->
      await User.deleteUser('AAA12345BB', defer(err, result))
      assert.equal(err, null)
      assert.equal(result.affectedRows, 0)
      done()

    it 'can delete a User without error', (done) ->
      await User.deleteUser(testUserPid, defer(err, result))
      assert.equal(err, null)
      done()

    it 'should no longer exist after deletion', (done) ->
      await User.getByUserPID(testUserPid, defer(err, result))
      assert.equal(err, null)
      assert.equal(result, undefined)
      done()

#TODO: More tests!!

# coffeelint: enable=no_implicit_returns