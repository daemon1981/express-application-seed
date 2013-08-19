mongoose = require 'mongoose'
moment   = require 'moment'
pwd      = require 'pwd'

Schema   = mongoose.Schema

UserSchema = new Schema(
  firstName:    String
  lastName:     String
  email:        type: String, required: true
  salt:         type: String
  picture:      type: String
  passwordHash: String
  facebook:
    id:       String
    name:     String
  twitter:
    id:       String
    name:     String
  regeneratePasswordKey: String
  regeneratePasswordDate: Date
)

###
Statics
###

UserSchema.statics.signup = (email, password, done) ->
  self = this
  newUser = new self(email: email)
  newUser.updatePassword password, done

UserSchema.statics.isValidUserPassword = (email, password, done) ->
  this.findOne
    email: email
  , (err, user) ->
    return done(err)  if err
    unless user
      return done(null, false,
        message: "Incorrect email."
      )
    pwd.hash password, user.salt, (err, hash) ->
      return done(err) if err
      return done(null, user)  if hash is user.passwordHash
      done null, false,
        message: "Incorrect password."

UserSchema.statics.findOrCreateFaceBookUser = (profile, done) ->
  self = this
  this.findOne
    'facebook.id': profile.id
  , (err, user) ->
    if user
      done null, user
    else
      new self(
        email:   profile.emails[0].value
        facebook:
          id:    profile.id
          name:  profile.displayName
      ).save done

###
Methods
###

UserSchema.methods.requestResetPassword = (callback) ->
  self = this
  pwd.hash this.salt, (err, salt, hash) ->
    callback(err) if err
    self.regeneratePasswordKey  = salt.match(/([0-9a-z])/ig).slice(0, 50).join('')
    self.regeneratePasswordDate = moment()
    self.save (err) ->
      callback(err) if err
      callback(null, self)

UserSchema.methods.updatePassword = (password, done) ->
  self = this
  pwd.hash password, (err, salt, hash) ->
    throw err  if err
    self.salt         = salt
    self.passwordHash = hash
    # reset password reset params
    self.regeneratePasswordKey = null
    self.regeneratePasswordDate = null
    self.save done

User = mongoose.model "User", UserSchema

module.exports = User
