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

describe 'Contact', ->
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

  describe 'Contact page', ->

    describe 'When logged in', ->

      describe 'Accessing page', ->
        it 'should return 200', (done) ->
          connectedRequest.get('/contact').expect(200).end done
        it 'should not display captcha', (done) ->
          connectedRequest.get('/contact').expect(200).end (err, res) ->
            should.not.exist(err)
            $body = $(res.text)
            $body.find('[for="recaptcha_challenge_field"]').length.should.equal(0)
            done()

      describe 'Submitting information', ->
        it 'should return 200 with error for captcha if not validated'
        it 'should return 200 with error for email and message if not validated but captcha validated'
        it 'should redirect to /contact/confirmation if all information are send and validated'

    describe 'When logged out', ->

      describe 'Accessing page', ->
        it 'should return 200', (done) ->
          request(new App()).get('/contact').expect(200).end done
        it 'should display captcha', (done) ->
          request(new App()).get('/contact').expect(200).end (err, res) ->
            should.not.exist(err)
            $body = $(res.text)
            $body.find('[for="recaptcha_challenge_field"]').length.should.equal(1)
            done()

      describe 'Submitting information', ->
        it 'should return 200 with error for email and message if not validated but captcha validated'
        it 'should redirect to /contact/confirmation if all information are send and validated'
