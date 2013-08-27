mongoose = require 'mongoose'
moment   = require 'moment'
pwd      = require 'pwd'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId
User     = require './user'

ContactMessagesSchema = new Schema(
  subject:       type: String, required: true, max: 200,  min: 5
  message:       type: String, required: true, max: 2000, min: 100
  email:         type: String, match: /@/
  user:          type: ObjectId, ref: 'User'
)

Contact = mongoose.model "Contact", ContactMessagesSchema

module.exports = Contact
