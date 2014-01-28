mongoose           = require("mongoose")
MongooseUserPlugin = require("mongoose-user-plugin")

UserSchema = new mongoose.Schema()
UserSchema.plugin MongooseUserPlugin

User = mongoose.model("User", UserSchema)
module.exports = User
