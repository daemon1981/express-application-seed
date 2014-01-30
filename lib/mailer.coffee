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
    return require('path').join(__dirname, '../templates/emails/') + locale

  # send mail with defined transport object
  @doSendMail = (mailOptions, callback) ->
    smtpTransport.sendMail mailOptions, (err, response) ->
      return callback(err) if err
      callback(err, response)

  @sendMail = (templateName, subject, locale, emailTo, bodyData, callback) ->
    emailTemplates self.getTemplatesDir(locale), (err, template) ->
      return callback(err) if err
      template templateName, bodyData, (err, html, text) ->
        return callback(err) if err
        self.doSendMail
          from: config.mailer.sender['no-reply']
          to: emailTo
          subject: subject
          text: text
          html: html
        , callback

  @sendSignupConfirmation = (locale, subject, emailTo, validationUrl, callback) ->
    @sendMail "signup", subject, locale, emailTo, {url: validationUrl}, callback

  @sendAccountValidatedConfirmation = (locale, subject, emailTo, callback) ->
    @sendMail "accountValidated", subject, locale, emailTo, {}, callback

  @sendRequestForResetingPassword = (locale, subject, emailTo, url, callback) ->
    @sendMail "requestForResetingPassword", subject, locale, emailTo, {url: url}, callback

  @sendPasswordReseted = (locale, subject, emailTo, url, callback) ->
    @sendMail "passwordReseted", subject, locale, emailTo, {url: url, email: emailTo}, callback

  @sendContactConfirmation = (locale, subject, emailTo, callback) ->
    @sendMail "contactConfirmation", subject, locale, emailTo, {}, callback

  return
