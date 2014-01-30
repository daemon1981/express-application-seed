require '../../../bootstrap.coffee'

assert       = require 'assert'
should       = require 'should'
sinon        = require 'sinon'
config       = require 'config'

Mailer       = require "../../../lib/mailer"

describe "Mailer", ->
  emailTo = 'toto@toto.com'
  emailFrom = 'no-reply@toto.com'
  locale = 'en'
  config.mailer.sender['no-reply'] = emailFrom
  mailer = {}

  beforeEach (done) ->
    mailer = new Mailer()
    mailer.doSendMail = sinon.stub(mailer, 'doSendMail', (mailOptions, callback) -> return callback(null, {}))
    done()

  checkSendMailArgs = (args, textVariables) ->
    objectData = args[0][0]
    assert.equal emailFrom, objectData.from
    assert.equal emailTo, objectData.to
    for variable in textVariables
      assert new RegExp(variable).test(objectData.text), variable + ' should be in text body'
    for variable in textVariables
      assert new RegExp(variable).test(objectData.html), variable + ' should be in html body'

  describe "When sending signup confirmation 'sendSignupConfirmation()'", ->
    it "should call sendMail", (done) ->
      validationUrl = 'http://dummy-url.com'
      mailer.sendSignupConfirmation locale, 'dummy-subject', emailTo, validationUrl, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [validationUrl])
        done()

  describe "When sending account validation confirmation 'sendAccountValidatedConfirmation()'", ->
    it "should call sendMail", (done) ->
      mailer.sendAccountValidatedConfirmation locale, 'dummy-subject', emailTo, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [])
        done()

  describe "When sending request for reseting password 'sendRequestForResetingPassword()'", ->
    url = 'http://dummy-url.com'
    it "should call sendMail", (done) ->
      mailer.sendRequestForResetingPassword locale, 'dummy-subject', emailTo, url, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [url])
        done()

  describe "When sending password reset process 'sendPasswordReseted()'", ->
    url = 'http://dummy-url.com'
    it "should call sendMail", (done) ->
      mailer.sendPasswordReseted locale, 'dummy-subject', emailTo, url, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [url, emailTo])
        done()

  describe "When sending contact confirmation 'sendContactConfirmation()'", ->
    it "should call sendMail", (done) ->
      mailer.sendContactConfirmation locale, 'dummy-subject', emailTo, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [])
        done()
