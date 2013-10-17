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

  return this.comments[this.comments.length - 1]._id

ThingySchema.methods.removeComment = (userId, commentId, callback) ->
  removeComment = (comments, commentId) ->
    comments = comments.filter (comment) ->
      return comment.creator isnt userId || comment._id isnt commentId

    for reply in comments
      reply.comments = removeComment(reply.comments, commentId)

    return comments

  this.comments = removeComment(this.comments, commentId)
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

ThingySchema.methods.getComment = (commentId) ->
  searchComment = (comments, commentId) ->
    for comment in comments
      if comment._id is commentId
        return comment
      comment = searchComment(comment.comments, commentId)
      return comment if comment isnt null
    null

  return searchComment(this.comments, commentId)

ThingySchema.methods.addReplyToComment = (userId, commentId, message, callback) ->
  comment = this.getComment(commentId)
  return callback(new Error('Comment doesn\'t exist')) if !comment

  reply =
    message:       message
    creator:       userId
  comment.comments.push(reply)

  this.save callback

ThingySchema.methods.addLikeToComment = (userId, commentId, callback) ->
  comment = this.getComment(commentId)
  return callback(new Error('Comment doesn\'t exist')) if !comment

  hasAlreadyLiked = comment.likes.some (likeUserId) ->
    return likeUserId is userId

  comment.likes.push userId  if !hasAlreadyLiked

  this.save callback

ThingySchema.methods.removeLikeToComment = (userId, commentId, callback) ->
  comment = this.getComment(commentId)
  return callback(new Error('Comment doesn\'t exist')) if !comment

  comment.likes = comment.likes.filter (likeUserId) ->
    return likeUserId isnt userId

  this.save callback

Thingy = mongoose.model "Thingy", ThingySchema

module.exports = Thingy
