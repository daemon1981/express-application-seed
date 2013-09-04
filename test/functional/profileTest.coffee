request      = require 'supertest'
assert       = require 'assert'
should       = require 'should'
async        = require 'async'
mongoose     = require 'mongoose'
App          = require '../../app'

fixtures     = require 'pow-mongoose-fixtures'
fixturesData = require '../../fixtures/test.coffee'

User = require '../../model/user'

describe '/profile', ->
  fakeUser = {}
  requestTest = {}

  describe '** Logged in **', ->
    before (done) ->
      async.series [(callback) ->
        fixtures.load fixturesData.testUser, mongoose.connection, callback
      , (callback) ->
        User.findById fixturesData.testUser.User.fakeUser._id, (err, user) ->
          fakeUser = user
          requestTest = request(new App(fakeUser))
          callback()
      ], done

    describe 'GET', ->
      it 'should return 200', (done) ->
        requestTest.get('/profile').expect(200).end (err, res) ->
          should.not.exist err
          done()

    describe 'POST', ->
      it 'should not delete already saved params', (done) ->
        newFirstName = 'Titi'
        requestTest.post('/profile').send(firstName: newFirstName).expect(302).end (err, res) ->
          return done(err) if err
          res.header['location'].should.include('/profile')
          User.findOne firstName: newFirstName, (err, modifiedUser) ->
            should.not.exist(err)
            assert.equal fakeUser.lastName, modifiedUser.lastName
            done()

  describe '** Logged out **', ->
    describe 'GET', ->
      it 'should return 302', (done) ->
        request(new App()).get('/profile').expect(302).end (err, res) ->
          should.not.exist err
          done()
