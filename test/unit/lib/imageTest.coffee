require '../../../bootstrap.coffee'

assert       = require 'assert'
should       = require 'should'
sinon        = require 'sinon'
config       = require 'config'
mongoose     = require 'mongoose'
fixtures     = require 'pow-mongoose-fixtures'

Image       = require "../../../lib/image"
User        = require "../../../model/user"

image = new Image(config.Upload)

describe "image", ->
  userEmail = 'toto@toto.com'

  before (done) ->
    fixtures.load {User: []}, mongoose.connection, (err) ->
      done(err) if err
      User.signup userEmail, 'passwd', done

  describe "#validate()", ->
    it "should validate when file is correct", (done) ->
      image.validate { size: 30, name: 'dummy.jpg' }, (err) ->
        should.not.exists err
        done()
    it "should fails when file too small", (done) ->
      image.validate { size: 0, name: 'dummy.jpg' }, (err) ->
        should.exists err
        assert.equal 'File is too small', err.message
        done()
    it "should fails when file too big", (done) ->
      image.validate { size: 20000000, name: 'dummy.jpg' }, (err) ->
        should.exists err
        assert.equal 'File is too big', err.message
        done()
    it "should validate when file name is not allowed", (done) ->
      image.validate { size: 30, name: 'dummy' }, (err) ->
        should.exists err
        assert.equal 'Filetype not allowed', err.message
        done()

  describe "#createUserDir()", ->
    userTest = {}

    before (done) ->
      User.findOne {email: userEmail}, (err, user) ->
        userTest = user
        unlink __dirname + '/' + user.id
    it.only "plop", (done) ->
      image.createUserDir user, __dirname, (err) ->
        should.not.exists err
        done()
