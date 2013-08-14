nodemailer = require "nodemailer"
config     = require "config"

smtpTransport = nodemailer.createTransport("Sendmail")

# send mail with defined transport object
sendMail = (mailOptions) ->
  smtpTransport.sendMail mailOptions, (error, response) ->
    if error
      console.log error
    else
      console.log "Message sent: " + response.message

exports.sendSinupConfirmation = (email) ->
  sendMail
    from: config.mailer.sender['no-reply']
    to: email
    subject: "Welcome to Super Site !"
    text: "Welcome to Super Site ! Hope you'll enjoy it"
    html: "<p>Welcome to Super Site ! Hope you'll enjoy it</p>"

exports.sendForgotPassword = (email, url) ->
  sendMail
    from: config.mailer.sender['no-reply']
    to: email
    subject: "Reset your password"
    text: "Reset your password going to this " + url
    html: '<p>Reset your password by clicking here <a href="' + url + '">url<a></p><p>or copy and paste this url: ' + url + '</p>'
