require '../../../bootstrap.coffee'

assert       = require 'assert'
should       = require 'should'
sinon        = require 'sinon'

Mailer       = require "../../../lib/mailer"

mailer = new Mailer()

describe "mailer", ->
  before (done) ->
    mailer.sendMail = sinon.stub(mailer, 'sendMail', (mailOptions, callback) -> return callback(null, {}))
    done()

  describe "#sendSignupConfirmation()", ->
    it "should call sendMail", (done) ->
      mailer.sendSignupConfirmation 'toto@toto.com', (err, response) ->
        should.not.exists(err)
        assert(mailer.sendMail.called);
        done()

  describe "#sendForgotPassword()", ->
    it "should call sendMail", (done) ->
      mailer.sendForgotPassword 'toto@toto.com', 'http://dummy-url.com', (err, response) ->
        should.not.exists(err)
        assert(mailer.sendMail.called);
        done()

  describe "#sendPasswordReseted()", ->
    it "should call sendMail", (done) ->
      mailer.sendPasswordReseted 'toto@toto.com', 'http://dummy-url.com', (err, response) ->
        should.not.exists(err)
        assert(mailer.sendMail.called);
        done()
