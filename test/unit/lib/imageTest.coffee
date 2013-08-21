require '../../../bootstrap.coffee'

assert       = require 'assert'
should       = require 'should'
async        = require 'async'
sinon        = require 'sinon'
config       = require 'config'
mongoose     = require 'mongoose'
fixtures     = require 'pow-mongoose-fixtures'
fs           = require 'fs'
exec         = require('child_process').exec

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
    testDir  = '/tmp/test-createUserDir'

    before (done) ->
      User.findOne {email: userEmail}, (err, user) ->
        userTest = user
        fs.exists testDir, (exists) ->
          if exists
            exec 'rm -r ' + testDir, (err) ->
              fs.mkdir testDir, done
          else
            fs.mkdir testDir, done

    it "should create user directories", (done) ->
      image.createUserDir userTest, testDir, (err) ->
        should.not.exists err
        fs.exists testDir + '/' + userTest._id + '/picture/thumbnail', (exists) ->
          assert.ok exists
          done()

  describe "#saveUserPicture()", ->
    userTest = {}
    testDir  = '/tmp/test-createUserDir'
    filePath = testDir + '/homer.jpg'

    before (done) ->
      User.findOne {email: userEmail}, (err, user) ->
        userTest = user
        fs.exists testDir, (exists) ->
          if exists
            exec 'rm -r ' + testDir, (err) ->
              fs.mkdir testDir, (err) ->
                exec 'cp ' + __dirname + '/homer.jpg ' + testDir, done
          else
            fs.mkdir testDir, (err) ->
              exec 'cp ' + __dirname + '/homer.jpg ' + testDir, done

    it "should save image in user directories", (done) ->
      image.saveUserPicture userTest, { size: 30, name: 'homer.jpg', path: filePath }, (err) ->
        should.not.exists err
        checkExists = (file, next) ->
          fs.exists file, (exists) ->
            assert.ok exists, file + ' doesn\'t exist'
            next()
        async.eachSeries [
          testDir + '/' + userTest._id + '/picture/thumbnail'
        , testDir + '/' + userTest._id + '/picture/thumbnail/homer.jpg'
        ], checkExists, done
