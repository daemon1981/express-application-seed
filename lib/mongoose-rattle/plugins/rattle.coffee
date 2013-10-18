mongoose = require 'mongoose'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId

module.exports = exports = rattlePlugin = (schema, options) ->

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

  schema.add
    likes:         [type: ObjectId, ref: 'User']
    comments:      [CommentSchema]

  schema.pre "save", (next) ->
    # => trigger creation activity
    next()

  schema.methods.addComment = (userId, message, callback) ->
    comment =
      message:       message
      creator:       userId
    this.comments.push(comment)

    this.save (err, data) ->
      return callback(err) if err isnt null
      # => trigger addComment activity
      callback(err, data)

    return this.comments[this.comments.length - 1]._id

  schema.methods.removeComment = (userId, commentId, callback) ->
    removeComment = (comments, commentId) ->
      comments = comments.filter (comment) ->
        return comment.creator isnt userId || comment._id isnt commentId

      for reply in comments
        reply.comments = removeComment(reply.comments, commentId)

      return comments

    this.comments = removeComment(this.comments, commentId)

    this.save (err, data) ->
      return callback(err) if err isnt null
      # => trigger removeComment activity
      callback(err, data)

  schema.methods.addLike = (userId, callback) ->
    hasAlreadyLiked = this.likes.some (likeUserId) ->
      return likeUserId is userId

    this.likes.push userId if !hasAlreadyLiked

    this.save (err, data) ->
      return callback(err) if err isnt null
      # => trigger addLike activity
      callback(err, data)

  schema.methods.removeLike = (userId, callback) ->
    this.likes = this.likes.filter (likeUserId) ->
      return likeUserId isnt userId

    this.save (err, data) ->
      return callback(err) if err isnt null
      # => trigger removeLike activity
      callback(err, data)

  schema.methods.getComment = (commentId) ->
    searchComment = (comments, commentId) ->
      for comment in comments
        if comment._id is commentId
          return comment
        comment = searchComment(comment.comments, commentId)
        return comment if comment isnt null
      null

    return searchComment(this.comments, commentId)

  schema.methods.addReplyToComment = (userId, commentId, message, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    reply =
      message:       message
      creator:       userId
    comment.comments.push(reply)

    this.save (err, data) ->
      return callback(err) if err isnt null
      # => trigger addComment activity
      callback(err, data)

  schema.methods.addLikeToComment = (userId, commentId, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    hasAlreadyLiked = comment.likes.some (likeUserId) ->
      return likeUserId is userId

    comment.likes.push userId  if !hasAlreadyLiked

    this.save (err, data) ->
      return callback(err) if err isnt null
      # => trigger addLike activity
      callback(err, data)

  schema.methods.removeLikeToComment = (userId, commentId, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    comment.likes = comment.likes.filter (likeUserId) ->
      return likeUserId isnt userId

    this.save (err, data) ->
      return callback(err) if err isnt null
      # => trigger removeLike activity
      callback(err, data)
