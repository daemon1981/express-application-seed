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

describe '** profile **', ->
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

  describe '** /profile **', ->

    describe '** Logged in **', ->

      describe 'GET', ->
        it 'should return 200', (done) ->
          connectedRequest.get('/profile').expect(200).end (err, res) ->
            should.not.exist err
            done()

      describe 'POST', ->
        it 'should not delete already saved params', (done) ->
          newFirstName = 'Titi'
          connectedRequest.post('/profile').send(firstName: newFirstName).expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            User.findOne firstName: newFirstName, (err, modifiedUser) ->
              should.not.exist(err)
              assert.equal fakeUser.lastName, modifiedUser.lastName
              done()

    describe '** Logged out **', ->

      describe 'GET', ->
        it 'should redirect to /login', (done) ->
          request(new App()).get('/profile').expect(302).end (err, res) ->
            should.not.exist err
            res.header['location'].should.include('/login')
            done()

  describe '** /forgot/password **', ->

    describe '** Logged in **', ->
      describe 'GET', ->
        it 'should redirect to /profile', (done) ->
          connectedRequest.get('/forgot/password').expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            done()
      describe 'POST', ->
        it 'should redirect to /profile', (done) ->
          connectedRequest.post('/forgot/password').expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            done()

    describe '** Logged out **', ->
      describe 'GET', ->
        it 'should return 200', (done) ->
          request(new App()).get('/forgot/password').expect(200).end done
      describe 'POST', ->
        it 'should return 200 with warning "×Email was not found" if email not found', (done) ->
          request(new App()).post('/forgot/password')
            .send(email: 'not@known.email')
            .expect(200)
            .end (err, res) ->
              should.not.exist(err)
              $body = $(res.text)
              $body.find('.alert.alert-warning').text().should.equal('×Email was not found')
              done()
        it 'should redirect to /forgot/password if email is found', (done) ->
          request(new App()).post('/forgot/password')
            .send(email: fixturesData.testUser.User.fakeUser.email)
            .expect(302)
            .end (err, res) ->
              should.not.exist(err)
              res.header['location'].should.include('/forgot/password')
              done()
