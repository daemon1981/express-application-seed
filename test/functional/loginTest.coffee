request      = require 'supertest'
assert       = require 'assert'
should       = require 'should'
async        = require 'async'
mongoose     = require 'mongoose'
App          = require '../../app'

fixtures     = require 'pow-mongoose-fixtures'
fixturesData = require '../../fixtures/test.coffee'

User = require '../../model/user'

describe 'Login', ->
  requestTest = {}

  describe 'When logged in', ->
    before (done) ->
      async.series [(callback) ->
        fixtures.load fixturesData.testUser, mongoose.connection, callback
      , (callback) ->
        User.findById fixturesData.testUser.User.fakeUser._id, (err, user) ->
          requestTest = request(new App(user))
          callback()
      ], done

    describe 'Accessing login page', ->
      it 'should redirect to /profile', (done) ->
        requestTest.get('/login').expect(302).end (err, res) ->
          should.not.exist err
          res.header.location.should.equal('/profile')
          done()

  describe 'When logged out', ->
    before (done) ->
      fixtures.load fixturesData.testUser, mongoose.connection, done

    describe 'Accessing login page', ->
      it 'should return 200', (done) ->
        request(new App()).get('/login').expect(200).end (err, res) ->
          should.not.exist err
          done()

    describe 'Submitting login and password', ->
      describe 'User is validated', ->
        userData = fixturesData.testUser.User.fakeUser;
        it 'should redirect to /profile when authentication is successfull', (done) ->
          request(new App()).post('/login')
            .send(email: userData.email, password: 'plop')
            .expect(302).end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/profile')
              done()
        it 'should redirect to /login when authentication is wrong', (done) ->
          request(new App()).post('/login')
            .send(email: userData.email, password: 'badpassword')
            .expect(302).end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/login')
              done()

      describe 'User is not validated', ->
        userData = fixturesData.testUser.User.fakeUserNotValidated;
        it 'should redirect to /login even if password is correct', (done) ->
          request(new App()).post('/login')
            .send(email: userData.email, password: 'plip')
            .expect(302).end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/login')
              done()
