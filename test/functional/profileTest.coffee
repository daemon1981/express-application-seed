request      = require 'supertest'
assert       = require 'assert'
should       = require 'should'
async        = require 'async'
mongoose     = require 'mongoose'
$            = require 'jquery'
App          = require '../../app'

fixtures     = require 'pow-mongoose-fixtures'
fixturesData = require '../../fixtures/test.coffee'

User = require '../../model/user'

describe 'Profile', ->
  fakeUser = {}
  connectedRequest = {}

  before (done) ->
    async.series [(callback) ->
      fixtures.load fixturesData.testUser, mongoose.connection, callback
    , (callback) ->
      User.findById fixturesData.testUser.User.fakeUser._id, (err, user) ->
        fakeUser = user
        connectedRequest = request(new App(fakeUser))
        callback()
    ], done

  describe 'Profile page', ->

    describe 'When logged in', ->

      describe 'Accessing profile page', ->
        it 'should return 200', (done) ->
          connectedRequest.get('/profile').expect(200).end (err, res) ->
            should.not.exist err
            done()

      describe 'Submitting profile information', ->
        it 'should not delete already saved params', (done) ->
          newFirstName = 'Titi'
          connectedRequest.post('/profile').send(firstName: newFirstName).expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            User.findOne firstName: newFirstName, (err, modifiedUser) ->
              should.not.exist(err)
              assert.equal fakeUser.lastName, modifiedUser.lastName
              done()

    describe 'When logged out', ->

      describe 'Accessing profile page', ->
        it 'should redirect to /login', (done) ->
          request(new App()).get('/profile').expect(302).end (err, res) ->
            should.not.exist err
            res.header['location'].should.include('/login')
            done()

  describe 'Forgot password page', ->

    describe 'When logged in', ->

      describe 'Accessing forgot password page', ->
        it 'should redirect to /profile', (done) ->
          connectedRequest.get('/forgot/password').expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            done()

      describe 'Trying submitting email by http post call', ->
        it 'should redirect to /profile', (done) ->
          connectedRequest.post('/forgot/password').expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            done()

    describe 'When logged out', ->

      describe 'Accessing forgot password page', ->
        it 'should return 200', (done) ->
          request(new App()).get('/forgot/password').expect(200).end done

      describe 'Submitting email', ->
        it 'should return 200 with warning "×Email was not found" if email not found', (done) ->
          request(new App()).post('/forgot/password')
            .send(email: 'not@known.email')
            .expect(200)
            .end (err, res) ->
              should.not.exist(err)
              $body = $(res.text)
              $body.find('.alert.alert-warning').text().should.equal('×Email was not found')
              done()
        it 'should redirect to / if email is found', (done) ->
          request(new App()).post('/forgot/password')
            .send(email: fixturesData.testUser.User.fakeUser.email)
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/')
              done()

  describe 'Reset password page', ->
    before (done) ->
      fixtures.load fixturesData.testUser, mongoose.connection, done

    describe 'When logged in', ->

      describe 'Accessing reset password page', ->
        it 'should redirect to /profile', (done) ->
          connectedRequest.get('/reset/password').expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            done()

      describe 'Trying submitting by http post call', ->
        it 'should redirect to /profile', (done) ->
          connectedRequest.post('/reset/password').expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            done()

    describe 'When logged out', ->

      describe 'Accessing reset password page', ->
        it 'should redirect to homepage if not key in query', (done) ->
          request(new App()).get('/reset/password')
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/')
              done()
        it 'should redirect to homepage if key in query but no value', (done) ->
          request(new App()).get('/reset/password?key=')
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/')
              done()
        it 'should redirect to homepage if regeneratePasswordKey is not found', (done) ->
          request(new App()).get('/reset/password?key=not-found-regenerate-password-key')
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/')
              done()
        it 'should redirect to homepage if regeneratePasswordKey is found but account is not validated', (done) ->
          url = '/reset/password?key=' + fixturesData.testUser.User.fakeUserNotValidated.regeneratePasswordKey
          request(new App()).get(url)
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/')
              done()
        it 'should return 200 if regeneratePasswordKey is found and account is validated', (done) ->
          url = '/reset/password?key=' + fixturesData.testUser.User.fakeUser.regeneratePasswordKey
          request(new App()).get(url)
            .expect(200)
            .end done

      describe 'Submitting new password', ->
        it 'should redirect to homepage if regeneratePasswordKey is not found', (done) ->
          request(new App()).post('/reset/password')
            .send(
              regeneratePasswordKey: 'not-found-regenerate-password-key'
            )
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/')
              done()
        it 'should redirect to homepage if regeneratePasswordKey is found but account is not validated', (done) ->
          request(new App()).post('/reset/password')
            .send(
              regeneratePasswordKey: fixturesData.testUser.User.fakeUserNotValidated.regeneratePasswordKey
            )
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/')
              done()
        it 'should return 200 with error "×You must provide a password" if password not defined', (done) ->
          request(new App()).post('/reset/password')
            .send(
              regeneratePasswordKey: fixturesData.testUser.User.fakeUser.regeneratePasswordKey
            )
            .expect(200)
            .end (err, res) ->
              should.not.exist(err)
              $body = $(res.text)
              $body.find('.alert.alert-danger').text().should.equal('×You must provide a password')
              done()
        it 'should return 200 with error "×You must provide a password" if password empty string', (done) ->
          request(new App()).post('/reset/password')
            .send(
              regeneratePasswordKey: fixturesData.testUser.User.fakeUser.regeneratePasswordKey,
              password: ''
            )
            .expect(200)
            .end (err, res) ->
              should.not.exist(err)
              $body = $(res.text)
              $body.find('.alert.alert-danger').text().should.equal('×You must provide a password')
              done()
        it 'should return 200 with error "×You must provide a password more complicated" if password too simple', (done) ->
          request(new App()).post('/reset/password')
            .send(
              regeneratePasswordKey: fixturesData.testUser.User.fakeUser.regeneratePasswordKey,
              password: 'yo'
            )
            .expect(200)
            .end (err, res) ->
              should.not.exist(err)
              $body = $(res.text)
              $body.find('.alert.alert-danger').text().should.equal('×You must provide a password more complicated')
              done()
        it 'should redirect to /login if email is found and password enough complex', (done) ->
          request(new App()).post('/reset/password')
            .send(
              regeneratePasswordKey: fixturesData.testUser.User.fakeUser.regeneratePasswordKey,
              password: 'enough complex'
            )
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/login')
              done()
