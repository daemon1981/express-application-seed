require '../../../bootstrap.coffee'

assert       = require 'assert'
should       = require 'should'
sinon        = require 'sinon'
config       = require 'config'

Mailer       = require "../../../lib/mailer"
templateRootDir = require('path').join(__dirname, '../../../templates/emails/')

describe "Mailer", ->
  emailTo = 'toto@toto.com'
  emailFrom = 'no-reply@toto.com'
  locale = 'en'
  config.mailer.sender['no-reply'] = emailFrom
  mailer = {}

  beforeEach (done) ->
    mailer = new Mailer("Sendmail", templateRootDir)
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

  describe "When sending signup confirmation", ->
    it "should call sendMail", (done) ->
      validationUrl = 'http://dummy-url.com'
      mailer.sendMail locale, "signup", 'dummy-subject', emailTo, {url: validationUrl}, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [validationUrl])
        done()

  describe "When sending account validation confirmation", ->
    it "should call sendMail", (done) ->
      mailer.sendMail locale, "accountValidated", 'dummy-subject', emailTo, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [])
        done()

  describe "When sending request for reseting password", ->
    url = 'http://dummy-url.com'
    it "should call sendMail", (done) ->
      mailer.sendMail locale, "requestForResetingPassword", 'dummy-subject', emailTo, {url: url}, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [url])
        done()

  describe "When sending password reset process", ->
    url = 'http://dummy-url.com'
    it "should call sendMail", (done) ->
      mailer.sendMail locale, "passwordReseted", 'dummy-subject', emailTo, {url: url, email: emailTo}, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [url, emailTo])
        done()

  describe "When sending contact confirmation", ->
    it "should call sendMail", (done) ->
      mailer.sendMail locale, "contactConfirmation", 'dummy-subject', emailTo, (err, response) ->
        should.not.exists(err)
        assert(mailer.doSendMail.called)
        checkSendMailArgs(mailer.doSendMail.args, [])
        done()
