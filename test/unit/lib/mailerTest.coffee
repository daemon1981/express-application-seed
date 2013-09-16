require '../../../bootstrap.coffee'

assert       = require 'assert'
should       = require 'should'
sinon        = require 'sinon'

Mailer       = require "../../../lib/mailer"

mailer = new Mailer()

describe "Mailer", ->
  before (done) ->
    mailer.sendMail = sinon.stub(mailer, 'sendMail', (mailOptions, callback) -> return callback(null, {}))
    done()

  describe "When sending signup confirmation 'sendSignupConfirmation()'", ->
    it "should call sendMail", (done) ->
      mailer.sendSignupConfirmation 'en', 'toto@toto.com', 'http://dummy-url.com', (err, response) ->
        should.not.exists(err)
        assert(mailer.sendMail.called);
        done()

  describe "When sending account validation confirmation 'sendAccountValidatedConfirmation()'", ->
    it "should call sendMail", (done) ->
      mailer.sendAccountValidatedConfirmation 'en', 'toto@toto.com', (err, response) ->
        should.not.exists(err)
        assert(mailer.sendMail.called);
        done()

  describe "When sending forgot password process 'sendForgotPassword()'", ->
    it "should call sendMail", (done) ->
      mailer.sendForgotPassword 'en', 'toto@toto.com', 'http://dummy-url.com', (err, response) ->
        should.not.exists(err)
        assert(mailer.sendMail.called);
        done()

  describe "When sending password reset process 'sendPasswordReseted()'", ->
    it "should call sendMail", (done) ->
      mailer.sendPasswordReseted 'en', 'toto@toto.com', 'http://dummy-url.com', (err, response) ->
        should.not.exists(err)
        assert(mailer.sendMail.called);
        done()

  describe "When sending contact confirmation 'sendContactConfirmation()'", ->
    it "should call sendMail", (done) ->
      mailer.sendContactConfirmation 'en', 'toto@toto.com', (err, response) ->
        should.not.exists(err)
        assert(mailer.sendMail.called);
        done()
