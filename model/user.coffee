mongoose = require 'mongoose'
moment   = require 'moment'
pwd      = require 'pwd'

Schema   = mongoose.Schema

UserSchema = new Schema(
  firstName:       String
  lastName:        String
  email:           type: String, required: true, unique: true, match: /@/
  salt:            type: String
  picture:         String
  passwordHash:    String
  validated:       type: Boolean, default: false
  validationKey:   type: String
  facebook:
    id:            String
    name:          String
  twitter:
    id:            String
    name:          String
  regeneratePasswordKey: String
  regeneratePasswordDate: Date
)

###
Statics
###

UserSchema.statics.signup = (email, password, done) ->
  self = this
  self.findOne {email: email}, (err, user) ->
    return done(err) if err
    unless !user
      return done(new Error("Email already exists."), null)
    newUser = new self(email: email)
    newUser.updatePassword password, (err) ->
      return done(err) if err
      newUser.generateRandomKey (err, key) ->
        newUser.validationKey = key
        newUser.save done

UserSchema.statics.accountValidator = (validationKey, done) ->
  this.findOne
    validationKey: validationKey
  , (err, user) ->
    return done(err)  if err
    unless user
      return done(new Error("No account found."), null)
    user.validated = true
    user.validationKey = null
    user.save done

UserSchema.statics.isValidUserPassword = (email, password, done) ->
  this.findOne
    email: email
  , (err, user) ->
    return done(err)  if err
    unless user
      return done(null, false,
        message: "Incorrect email."
      )
    unless user.validated is true
      return done(null, false,
        message: "Account not validated."
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
        email:     profile.emails[0].value
        validated: true
        facebook:
          id:    profile.id
          name:  profile.displayName
      ).save done

###
Methods
###

UserSchema.methods.generateRandomKey = (callback) ->
  pwd.hash this.salt, (err, salt, hash) ->
    return callback(err) if err
    callback null, salt.match(/([0-9a-z])/ig).slice(0, 50).join('')

UserSchema.methods.requestResetPassword = (callback) ->
  self = this
  this.generateRandomKey (err, key) ->
    callback(err) if err
    self.regeneratePasswordKey  = key
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
