require '../../../bootstrap.coffee'

async    = require 'async'
assert   = require 'assert'
should   = require 'should'
mongoose = require 'mongoose'
fixtures = require 'pow-mongoose-fixtures'

Thingy   = require "../../../model/thingy"
User     = require '../../../model/user'

ObjectId  = require('mongoose').Types.ObjectId;

describe "Thingy", ->
  thingy = {}
  thingyCreatorUser = new User()
  commentorUserId = new ObjectId()

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
      thingy.addComment commentorUserId, '', (err) ->
        should.exists(err)
        done()
    it "should append a new comment and return comment id", (done) ->
      commentId = thingy.addComment commentorUserId, 'dummy message', (err) ->
        should.not.exists(err)
        should.exists(commentId)
        Thingy.findById thingy._id, (err, updatedThingy) ->
          should.exists(updatedThingy)
          assert.equal(1, updatedThingy.comments.length)
          done()

  describe "When removing a comment", ->
    beforeEach (done) ->
      async.series [(callback) ->
        thingy.addComment commentorUserId, 'first dummy message', (err, updatedThingy) ->
          should.not.exists(err)
          thingy = updatedThingy
          callback()
      , (callback) ->
        thingy.addComment commentorUserId, 'second dummy message', (err, updatedThingy) ->
          should.not.exists(err)
          thingy = updatedThingy
          callback()
      ], done

    it "should fails if the user is not the creator", (done) ->
      thingy.removeComment 123, thingy.comments[0]._id, (err, updatedThingy) ->
        should.exists(updatedThingy)
        assert.equal(2, updatedThingy.comments.length)
        done()
    it "should remove comment if the user is the creator", (done) ->
      thingy.removeComment commentorUserId, thingy.comments[0]._id, (err, updatedThingy) ->
        should.exists(updatedThingy)
        assert.equal(1, updatedThingy.comments.length)
        done()

  describe "When adding a user like", ->
    it "should add one user like if user doesn't already liked", (done) ->
      thingy.addLike commentorUserId, (err, updatedThingy) ->
        assert.equal(1, updatedThingy.likes.length)
        done()

    it "shouldn't add an other user like if user already liked", (done) ->
      thingy.addLike commentorUserId, (err, updatedThingy) ->
        thingy.addLike commentorUserId, (err, updatedThingy) ->
          assert.equal(1, thingy.likes.length)
          done()

  describe "When removing a user like", ->
    userOneId = new ObjectId()
    userTwoId = new ObjectId()

    beforeEach (done) ->
      async.series [(callback) ->
        thingy.addLike commentorUserId, (err, updatedThingy) ->
          thingy = updatedThingy
          callback()
      , (callback) ->
        thingy.addLike userOneId, (err, updatedThingy) ->
          thingy = updatedThingy
          callback()
      ], done

    it "should not affect current likes list if user didn'nt already liked", (done) ->
      thingy.removeLike userTwoId, (err, updatedThingy) ->
        assert.equal(2, updatedThingy.likes.length)
        done()

    it "should remove user like from likes list if user already liked", (done) ->
      thingy.removeLike commentorUserId, (err, updatedThingy) ->
        assert.equal(1, updatedThingy.likes.length)
        done()

  describe "When getting a comment", ->
    userOneId = new ObjectId()
    userTwoId = new ObjectId()
    level1UserOneMsg = 'level1 message ' + userOneId
    level1UserTwoMsg = 'level1 message ' + userTwoId
    level2UserOneMsg = 'level2 message ' + userOneId
    level2UserTwoMsg = 'level2 message ' + userTwoId
    level3UserTwoMsg = 'level3 message ' + userOneId
    messageIds = {}

    beforeEach (done) ->
      thingy.comments = [
        message:       level1UserOneMsg
        creator:       userOneId
      ,
        message:       level1UserTwoMsg
        creator:       userTwoId
        comments: [
          message:       level2UserOneMsg
          creator:       userOneId
        ,
          message:       level2UserTwoMsg
          creator:       userTwoId
          comments: [
            message:       level3UserTwoMsg
            creator:       userOneId
          ]
        ]
      ]
      messageIds['level 1 ' + userOneId] = thingy.comments[0]._id;
      messageIds['level 1 ' + userTwoId] = thingy.comments[1]._id;
      messageIds['level 2 ' + userOneId] = thingy.comments[1].comments[0]._id;
      messageIds['level 2 ' + userTwoId] = thingy.comments[1].comments[1]._id;
      messageIds['level 3 ' + userOneId] = thingy.comments[1].comments[1].comments[0]._id;
      thingy.save done

    it "should retrieve null if comment doesn't exist", ->
      assert.equal(null, thingy.getComment(messageIds['n0t3x1t1n9']))
    it "should be able to retrieve a simple level comment", ->
      assert.equal(level1UserOneMsg, thingy.getComment(messageIds['level 1 ' + userOneId]).message)
      assert.equal(level1UserTwoMsg, thingy.getComment(messageIds['level 1 ' + userTwoId]).message)
    it "should be able to retrieve a second level comment", ->
      assert.equal(level2UserOneMsg, thingy.getComment(messageIds['level 2 ' + userOneId]).message)
      assert.equal(level2UserTwoMsg, thingy.getComment(messageIds['level 2 ' + userTwoId]).message)
    it "should be able to retrieve a third level comment", ->
      assert.equal(level3UserTwoMsg, thingy.getComment(messageIds['level 3 ' + userOneId]).message)

  describe "When adding a reply to a comment", ->
    userOneId = new ObjectId()
    userTwoId = new ObjectId()
    level1UserOneMsg = 'level1 message ' + userOneId
    level1UserOneMsgRef = 'level 1 ' + userOneId
    messageIds = {}

    beforeEach (done) ->
      thingy.comments = [
        message:       level1UserOneMsg
        creator:       userOneId
      ]
      messageIds[level1UserOneMsgRef] = thingy.comments[0]._id;
      thingy.save done

    it "should fails if comment doesn't exist", (done) ->
      thingy.addReplyToComment commentorUserId, 'n0t3x1t1n9', 'dummy message', (err, updatedThingy) ->
        should.exists(err)
        done()
    it "should fails if message length is out of min and max", (done) ->
      messageId = messageIds[level1UserOneMsgRef]
      thingy.addReplyToComment commentorUserId, messageId, '', (err, updatedThingy) ->
        should.exists(err)
        done()
    it "should append a new comment to the parent comment if parent comment exists", (done) ->
      messageId = messageIds[level1UserOneMsgRef]
      thingy.addReplyToComment commentorUserId, messageId, 'dummy message', (err, updatedThingy) ->
        assert.equal 1, updatedThingy.getComment(messageId).comments.length
        done()

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
