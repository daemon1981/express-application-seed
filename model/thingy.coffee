mongoose = require 'mongoose'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId
RattlePlugin = require '../lib/mongoose-rattle/plugins/rattle'

ThingySchema = new Schema(
  description:   type: String, required: true, max: 2000, min: 100
  picture:       type: String, required: true
  creator:       type: ObjectId, ref: 'User', required: true
  owner:         type: ObjectId, ref: 'User', required: true
)

ThingySchema.plugin RattlePlugin

Thingy = mongoose.model "Thingy", ThingySchema

module.exports = Thingy
