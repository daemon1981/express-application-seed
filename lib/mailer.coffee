config         = require "config"
nodemailer     = require "nodemailer"
emailTemplates = require('email-templates');

templatesDir   = require('path').join(__dirname, '../templates/emails')
smtpTransport  = nodemailer.createTransport("Sendmail")

module.exports = ->
  self = this

  # send mail with defined transport object
  @sendMail = (mailOptions, callback) ->
    smtpTransport.sendMail mailOptions, (err, response) ->
      return callback(err) if err
      callback(err, response)

  @sendSignupConfirmation = (email, validationUrl, callback) ->
    emailTemplates templatesDir, (err, template) ->
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

  @sendAccountValidatedConfirmation = (email, callback) ->
    emailTemplates templatesDir, (err, template) ->
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

  @sendForgotPassword = (email, url, callback) ->
    emailTemplates templatesDir, (err, template) ->
      return callback(err) if err
      template "forgotPassword", url: url, (err, html, text) ->
        return callback(err) if err
        self.sendMail
          from: config.mailer.sender['no-reply']
          to: email
          subject: "Reset your password"
          text: text
          html: html
        , callback

  @sendPasswordReseted = (email, url, callback) ->
    emailTemplates templatesDir, (err, template) ->
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

  @sendContactConfirmation = (email, callback) ->
    emailTemplates templatesDir, (err, template) ->
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
