request      = require 'supertest'
assert       = require 'assert'
should       = require 'should'
async        = require 'async'
mongoose     = require 'mongoose'
App          = require '../../app'

fixtures     = require 'pow-mongoose-fixtures'
fixturesData = require '../../fixtures/test.coffee'

User = require '../../model/user'

describe '** /login **', ->
  requestTest = {}

  describe '** Logged in **', ->
    before (done) ->
      async.series [(callback) ->
        fixtures.load fixturesData.testUser, mongoose.connection, callback
      , (callback) ->
        User.findById fixturesData.testUser.User.fakeUser._id, (err, user) ->
          requestTest = request(new App(user))
          callback()
      ], done

    describe 'GET', ->
      it 'should redirect to /profile', (done) ->
        requestTest.get('/login').expect(302).end (err, res) ->
          should.not.exist err
          res.header.location.should.equal('/profile')
          done()

  describe '** Logged out **', ->
    before (done) ->
      fixtures.load fixturesData.testUser, mongoose.connection, done

    describe 'GET', ->
      it 'should return 200', (done) ->
        request(new App()).get('/login').expect(200).end (err, res) ->
          should.not.exist err
          done()

    describe 'POST', ->
      describe 'User is validated', ->
        userData = fixturesData.testUser.User.fakeUser;
        it 'should redirect to /profile when authentication is successfull', (done) ->
          request(new App()).post('/login')
            .send(email: userData.email, password: 'plop')
            .expect(302).end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/profile')
              done()
        it 'should redirect to /profile when authentication is wrong', (done) ->
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
