config         = require "config"
nodemailer     = require "nodemailer"
emailTemplates = require 'email-templates'
_              = require('underscore')._

smtpTransport  = nodemailer.createTransport("Sendmail")

module.exports = ->
  self = this

  @getTemplatesDir = (locale) ->
    if _.indexOf(config.languages, locale) is -1
      locale = config.email.default.language
    return require('path').join(__dirname, '../templates/emails/' + locale)

  # send mail with defined transport object
  @sendMail = (mailOptions, callback) ->
    smtpTransport.sendMail mailOptions, (err, response) ->
      return callback(err) if err
      callback(err, response)

  @sendSignupConfirmation = (locale, email, validationUrl, callback) ->
    emailTemplates self.getTemplatesDir(locale), (err, template) ->
      return callback(err) if err
      template "signup", {url: validationUrl}, (err, html, text) ->
        return callback(err) if err
        self.sendMail
          from: config.mailer.sender['no-reply']
          to: email
          subject: "Please validate your account"
          text: text
          html: html
        , callback

  @sendAccountValidatedConfirmation = (locale, email, callback) ->
    emailTemplates self.getTemplatesDir(locale), (err, template) ->
      return callback(err) if err
      template "accountValidated", {}, (err, html, text) ->
        return callback(err) if err
        self.sendMail
          from: config.mailer.sender['no-reply']
          to: email
          subject: "Welcome to Super Site !"
          text: text
          html: html
        , callback

  @sendRequestForResetingPassword = (locale, email, url, callback) ->
    emailTemplates self.getTemplatesDir(locale), (err, template) ->
      return callback(err) if err
      template "requestForResetingPassword", url: url, (err, html, text) ->
        return callback(err) if err
        self.sendMail
          from: config.mailer.sender['no-reply']
          to: email
          subject: "Reset your password"
          text: text
          html: html
        , callback

  @sendPasswordReseted = (locale, email, url, callback) ->
    emailTemplates self.getTemplatesDir(locale), (err, template) ->
      return callback(err) if err
      template "passwordReseted", { url: url, email: email}, (err, html, text) ->
        return callback(err) if err
        self.sendMail
          from: config.mailer.sender['no-reply']
          to: email
          subject: "Your password has been reseted"
          text: text
          html: html
        , callback

  @sendContactConfirmation = (locale, email, callback) ->
    emailTemplates self.getTemplatesDir(locale), (err, template) ->
      return callback(err) if err
      template "contactConfirmation", {}, (err, html, text) ->
        return callback(err) if err
        self.sendMail
          from: config.mailer.sender['no-reply']
          to: email
          subject: "Your contact request has been received"
          text: text
          html: html
        , callback

  return
