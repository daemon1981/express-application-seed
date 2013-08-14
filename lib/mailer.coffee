config         = require "config"
nodemailer     = require "nodemailer"
emailTemplates = require('email-templates');

templatesDir   = require('path').join(__dirname, '../templates/emails')
smtpTransport  = nodemailer.createTransport("Sendmail")

module.exports = ->
  self = this

  # send mail with defined transport object
  this.sendMail = (mailOptions, callback) ->
    smtpTransport.sendMail mailOptions, (err, response) ->
      return callback(err) if err
      callback(err, response)

  this.sendSignupConfirmation = (email, callback) ->
    emailTemplates templatesDir, (err, template) ->
      return callback(err) if err
      template "signup", {}, (err, html, text) ->
        return callback(err) if err
        self.sendMail
          from: config.mailer.sender['no-reply']
          to: email
          subject: "Welcome to Super Site !"
          text: text
          html: html
        , callback

  this.sendForgotPassword = (email, url, callback) ->
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

  this.sendPasswordReseted = (email, url, callback) ->
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

  return
