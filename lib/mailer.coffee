config         = require "config"
nodemailer     = require "nodemailer"
emailTemplates = require 'email-templates'
_              = require('underscore')._

class Mailer

  ###*
   * Constructor
   * @param {string} type            type of smtp transport (SMTP, SES, SENDMAIL, STUB)
   * @param {string} templateRootDir template root dir
   * @param {string} options         smtp transport options
   * @see https://github.com/andris9/Nodemailer
   ###
  constructor: (@type, @templateRootDir, @options) ->
    @smtpTransport  = nodemailer.createTransport(@type, @options)

  ###*
   * Get template dir according to template root dir and locale
   * @param {string} locale locale of the template
   ###
  getTemplatesDir: (locale) ->
    return @templateRootDir + locale

  ###*
   * send mail with defined transport object
   * @param {string} mailParams        params for the email
   * @callback callback(err, response) callback function to run when the sending is completed
   ###
  doSendMail: (mailParams, callback) ->
    @smtpTransport.sendMail mailParams, (err, response) ->
      return callback(err) if err
      callback(err, response)

  ###*
   * send email according to a local and template
   * @param {string} locale        locale for the template
   * @param {string} templateName  template name
   * @param {string} subject       subject of the mail
   * @param {string} emailTo       email address recipient
   * @param {Object} [bodyData]    json containing values of the template data
   * @callback callback(err)
   ###
  sendMail: (locale, templateName, subject, emailTo, bodyData, callback) ->
    self = @

    if typeof bodyData == 'function'
      callback = bodyData
      bodyData = {}

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
