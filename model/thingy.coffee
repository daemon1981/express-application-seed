mongoose = require 'mongoose'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId
User     = require './user'

# Schema strategies for embedded comments
#
# http://docs.mongodb.org/ecosystem/use-cases/storing-comments/
# http://stackoverflow.com/questions/7992185/mongoose-recursive-embedded-document-in-coffeescript
# http://stackoverflow.com/questions/17416924/create-embedded-docs-with-mongoose-and-express

CommentSchema = new Schema()

CommentSchema.add
  message:       type: String, required: true, max: 2000, min: 1
  likes:         [type: ObjectId, ref: 'User']
  comments:      [CommentSchema]
  creator:       type: ObjectId, ref: 'User', required: true

ThingySchema = new Schema(
  description:   type: String, required: true, max: 2000, min: 100
  picture:       type: String, required: true
  creator:       type: ObjectId, ref: 'User', required: true
  owner:         type: ObjectId, ref: 'User', required: true
  likes:         [type: ObjectId, ref: 'User']
  comments:      [CommentSchema]
)

ThingySchema.methods.addComment = (userId, message, callback) ->
  comment =
    message:       message
    creator:       userId
  this.comments.push(comment)
  this.save callback

ThingySchema.methods.removeComment = (userId, commentId, callback) ->
  this.comments = this.comments.filter (comment) ->
    return comment.creator isnt userId || comment._id isnt commentId
  this.save callback

ThingySchema.methods.addLike = (userId, callback) ->
  hasAlreadyLiked = this.likes.some (likeUserId) ->
    return likeUserId is userId

  this.likes.push userId if !hasAlreadyLiked

  this.save callback

ThingySchema.methods.removeLike = (userId, callback) ->
  this.likes = this.likes.filter (likeUserId) ->
    return likeUserId isnt userId

  this.save callback

ThingySchema.methods.addReplyToComment = (userId, commentId, message) ->
ThingySchema.methods.removeReplyToComment = (userId, commentId) ->
ThingySchema.methods.addLikeToComment = (userId, commentId, callback) ->
ThingySchema.methods.removeLikeToComment = (userId, commentId, callback) ->
ThingySchema.methods.getComments = ->

Thingy = mongoose.model "Thingy", ThingySchema

module.exports = Thingy
