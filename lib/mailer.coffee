config         = require "config"
nodemailer     = require "nodemailer"
emailTemplates = require 'email-templates'
_              = require('underscore')._

class Mailer
  constructor: (@type, @templateRootDir, @options) ->
    @smtpTransport  = nodemailer.createTransport(@type, @options)

  getTemplatesDir: (locale) ->
    return @templateRootDir + locale

  # send mail with defined transport object
  doSendMail: (mailOptions, callback) ->
    @smtpTransport.sendMail mailOptions, (err, response) ->
      return callback(err) if err
      callback(err, response)

  sendMail: (locale, templateName, subject, emailTo, bodyData, callback) ->
    self = @
    emailTemplates @getTemplatesDir(locale), (err, template) ->
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

module.exports = Mailer
