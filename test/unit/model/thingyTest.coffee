require '../../../bootstrap.coffee'

async    = require 'async'
assert   = require 'assert'
should   = require 'should'
mongoose = require 'mongoose'
fixtures = require 'pow-mongoose-fixtures'

Thingy   = require "../../../model/thingy"
User     = require '../../../model/user'

describe "Thingy", ->
  thingy = {}
  thingyCreatorUser = new User()
  commentorUser = new User()

  beforeEach (done) ->
    thingyData =
      description: Array(201).join("d")
      picture:     'dummy-picture.jpg'
      creator:     thingyCreatorUser._id
      owner:       thingyCreatorUser._id
    async.series [(callback) ->
      Thingy.remove callback
    , (callback) ->
      new Thingy(thingyData).save (err, thingySaved) ->
        thingy = thingySaved
        callback()
    ], done

  describe "When adding a comment", ->
    it "should fails if message length is out of min and max", (done) ->
      thingy.addComment commentorUser, '', (err) ->
        should.exists(err)
        done()
    it "should append a new comment", (done) ->
      thingy.addComment commentorUser, 'dummy message', (err) ->
        should.not.exists(err)
        Thingy.findById thingy._id, (err, updatedThingy) ->
          should.exists(updatedThingy)
          assert.equal(1, updatedThingy.comments.length)
          done()
  describe "When removing a comment", ->
    beforeEach (done) ->
      thingy.addComment commentorUser, 'dummy message', (err, updatedThingy) ->
        should.not.exists(err)
        thingy = updatedThingy
        done()
    it "should fails if the user is not the creator", (done) ->
      thingy.removeComment 123, thingy.comments[0]._id, (err, updatedThingy) ->
        should.exists(updatedThingy)
        assert.equal(1, updatedThingy.comments.length)
        done()
    it "should remove comment if the user is the creator", (done) ->
      thingy.removeComment commentorUser, thingy.comments[0]._id, (err, updatedThingy) ->
        should.exists(updatedThingy)
        assert.equal(1, updatedThingy.comments.length)
        done()
  describe "When adding a user like", ->
    it "should add one user like if user doesn't already liked"
    it "shouldn't add an other user like if user already liked"
  describe "When removing a user like", ->
    it "should not affect current likes list if user didn'nt already liked"
    it "should remove user like from likes list if user already liked"
  describe "When adding a reply to a comment", ->
    it "should fails if message length is out of min and max"
    it "should fails if comment doesn't exist"
    it "should append a new comment to the parent comment if parent comment exists"
  describe "When removing a reply from a comment", ->
    it "should fails if the user is not the creator"
    it "should fails if parent comment doesn't exist"
    it "should remove comment if the user is the creator and parent comment exists"
  describe "When adding a user like to a comment", ->
    it "should fails if comment doesn't exist"
    it "should add one user like if user doesn't already liked and comment exists"
    it "shouldn't add an other user like if user already liked and comment exists"
  describe "When removing a user like from a comment", ->
    it "should fails if comment doesn't exist"
    it "should not affect current likes list if user didn'nt already liked"
    it "should remove user like from likes list if user already liked"
  describe "When getting comments", ->
    it "with a simple list of comments with no reply"
    it "with a simple list of comments with one level of replies"
    it "with a simple list of comments with three level of replies"
