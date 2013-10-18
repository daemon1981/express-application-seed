mongoose = require 'mongoose'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId
User     = require './user'

ActivitySchema = new Schema(
  type:          type: String, index: true
  objectLink:    type: ObjectId
  objectType:    type: String
  actor:         type: ObjectId, ref: 'User', required: true
  date:          type: Date, index: true
)

Activity = mongoose.model "Activity", ActivitySchema

module.exports = Activity
