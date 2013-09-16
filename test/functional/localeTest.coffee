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

requestTest = request(new App());

describe 'Locale', ->
  describe 'By default inspect Accept-Language in http header', ->
    beforeEach (done) ->
      fixtures.load {User: []}, mongoose.connection, done

    describe 'Study case when using req.locale (signing up)', ->
      email = 'new@email.com'
      it 'with Accept-Language fr-FR should register language "fr" to user', (done) ->
        requestTest.post('/signup')
          .set('Accept-Language', 'fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4')
          .send(email: email, password: 'password')
          .expect(302).end (err, res) ->
            should.not.exist(err)
            User.findOne {email: email}, (err, user) ->
              should.exist(user)
              user.language.should.equal = 'fr'
              done()
      it 'with Accept-Language fr should register language "fr" to user', (done) ->
        requestTest.post('/signup')
          .set('Accept-Language', 'fr;q=0.8,en-US;q=0.6,en;q=0.4')
          .send(email: email, password: 'password')
          .expect(302).end (err, res) ->
            should.not.exist(err)
            User.findOne {email: email}, (err, user) ->
              should.exist(user)
              user.language.should.equal = 'fr'
              done()
      it 'with Accept-Language en-US should register language "en" to user', (done) ->
        requestTest.post('/signup')
          .set('Accept-Language', 'en-US;q=0.6,en;q=0.4')
          .send(email: email, password: 'password')
          .expect(302).end (err, res) ->
            should.not.exist(err)
            User.findOne {email: email}, (err, user) ->
              should.exist(user)
              user.language.should.equal = 'en'
              done()
      it 'with Accept-Language en should register language "en" to user', (done) ->
        requestTest.post('/signup')
          .set('Accept-Language', 'en;q=0.6,en;q=0.4')
          .send(email: email, password: 'password')
          .expect(302).end (err, res) ->
            should.not.exist(err)
            User.findOne {email: email}, (err, user) ->
              should.exist(user)
              user.language.should.equal = 'en'
              done()

  describe 'Next priority goes to req.user.language', ->
    requestConnected = {}
    before (done) ->
      async.series [(callback) ->
        fixtures.load fixturesData.testUser, mongoose.connection, callback
      , (callback) ->
        User.findById fixturesData.testUser.User.fakeUser._id, (err, user) ->
          fakeUser = user
          requestConnected = request(new App(fakeUser))
          callback()
      ], done

    describe 'Study case when going to homepage with user connected (language = "fr")', ->
      it 'with Accept-Language en-US should display in french', (done) ->
        requestConnected.get('/')
          .set('Accept-Language', 'en;q=0.6,en;q=0.4')
          .expect(200).end (err, res) ->
            should.not.exist(err)
            $body = $(res.text)
            assert.equal 'Profil', $body.find('a[href="/profile"]:eq(0)').text()
            done()

  describe 'Next priority goes to query ?lang=', ->
    requestConnected = {}
    before (done) ->
      async.series [(callback) ->
        fixtures.load fixturesData.testUser, mongoose.connection, callback
      , (callback) ->
        User.findById fixturesData.testUser.User.englishFakeUser._id, (err, user) ->
          requestConnected = request(new App(user))
          callback()
      ], done

    describe 'Study case when ?lang=fr', ->
      it 'with Accept-Language en-US and connected user language "en" should display in french', (done) ->
        requestConnected.get('/?lang=fr')
          .set('Accept-Language', 'en;q=0.6,en;q=0.4')
          .expect(200).end (err, res) ->
            should.not.exist(err)
            $body = $(res.text)
            assert.equal 'Profil', $body.find('a[href="/profile"]:eq(0)').text()
            done()
