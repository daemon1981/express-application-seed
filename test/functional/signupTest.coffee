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

describe '** signing up **', ->
  connectedRequest = {}
  before (done) ->
    async.series [(callback) ->
      fixtures.load fixturesData.testUser, mongoose.connection, callback
    , (callback) ->
      User.findById fixturesData.testUser.User.fakeUser._id, (err, user) ->
        connectedRequest = request(new App(user))
        callback()
    ], done

  describe '** /signup **', ->

    describe '** Logged in **', ->
      describe 'GET', ->
        it 'should redirect to /profile', (done) ->
          connectedRequest.get('/signup').expect(302).end (err, res) ->
            should.not.exist err
            res.header.location.should.equal('/profile')
            done()

    describe '** Logged out **', ->

      describe 'GET', ->
        it 'should return 200', (done) ->
          request(new App()).get('/signup').expect(200).end done

      describe 'POST', ->
        describe 'User not already registered', ->
          it 'should redirect to /signupConfirmation when signup is successfull', (done) ->
            request(new App()).post('/signup')
              .send(email: 'new@email.com', password: 'password')
              .expect(302).end (err, res) ->
                should.not.exist(err)
                res.header['location'].should.include('/signupConfirmation')
                done()
          it 'should render /signup with error "×Form has errors" if email is missing', (done) ->
            request(new App()).post('/signup')
              .send(password: 'password')
              .expect(200).end (err, res) ->
                should.not.exist(err)
                $body = $(res.text)
                $body.find('.alert.alert-danger').text().should.equal('×Form has errors')
                done()
        describe 'User already registered', ->
          userData = fixturesData.testUser.User.fakeUser;
          it 'should render /signup with error "×Email already exists."', (done) ->
            request(new App()).post('/signup')
              .send(email: userData.email, password: 'password')
              .expect(200).end (err, res) ->
                should.not.exist(err)
                $body = $(res.text)
                $body.find('.alert.alert-danger').text().should.equal('×Email already exists.')
                done()

  describe '** /signupConfirmation **', ->

    describe '** Logged in **', ->
      describe 'GET', ->
        it 'should return 200', (done) ->
          connectedRequest.get('/signupConfirmation').expect(200).end done

    describe '** Logged out **', ->
      describe 'GET', ->
        it 'should return 200', (done) ->
          request(new App()).get('/signupConfirmation').expect(200).end done

  describe '** /signupValidation **', ->

    describe '** Logged in **', ->
      describe 'GET', ->
        it 'should return 200', (done) ->
          connectedRequest.get('/signupValidation').expect(200).end done

    describe '** Logged out **', ->
      describe 'GET', ->
        it 'should return 200', (done) ->
          request(new App()).get('/signupValidation').expect(200).end done

  describe '** /signup/validation **', ->

    describe '** Logged in **', ->
      describe 'GET', ->
        it 'should return 200', (done) ->
          connectedRequest.get('/signup/validation').expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/profile')
            done()

    describe '** Logged out **', ->
      describe 'GET', ->
        it 'should redirect to /signupValidation if no user has this key', (done) ->
          url = '/signup/validation?key=not-existing-key'
          request(new App()).get(url).expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/')
            done()
        it 'should redirect to /signupValidation if key is correct', (done) ->
          url = '/signup/validation?key=' + fixturesData.testUser.User.fakeUserNotValidated.validationKey
          request(new App()).get(url).expect(302).end (err, res) ->
            should.not.exist(err)
            res.header['location'].should.include('/signupValidation')
            done()
