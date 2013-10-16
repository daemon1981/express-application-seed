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

ThingySchema.methods.addComment = (user, message, callback) ->
  comment =
    message:       message
    creator:       user
  this.comments.push(comment)
  this.save callback

ThingySchema.methods.removeComment = (user, commentId, callback) ->
  this.comments = this.comments.filter (comment) ->
    return comment.creator isnt user._id || comment._id isnt commentId
  this.save callback

ThingySchema.methods.addLike = (user) ->
ThingySchema.methods.removeLike = (user) ->
ThingySchema.methods.addReplyToComment = (user, commentId, message) ->
ThingySchema.methods.removeReplyToComment = (user, commentId) ->
ThingySchema.methods.addLikeToComment = (user, commentId) ->
ThingySchema.methods.removeLikeToComment = (user, commentId) ->
ThingySchema.methods.getComments = ->

Thingy = mongoose.model "Thingy", ThingySchema

module.exports = Thingy
