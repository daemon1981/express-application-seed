passport = require 'passport'
config   = require 'config'
request  = require 'request'

User     = require('../model/user')
Contact  = require('../model/contact')
Mailer   = require('../lib/mailer')
Image    = require('../lib/image')

image  = new Image(config.Upload)
mailer = new Mailer()

module.exports = (app) ->
  # Helpers
  validCaptcha = (req, res, next) ->
    if req.isAuthenticated()
      next()

    requestData =
      privatekey: config.reCaptcha.privateKey
      remoteip:   req.ip
      challenge:  req.body.recaptcha_challenge_field
      response:   req.body.recaptcha_response_field
    request.post 'http://www.google.com/recaptcha/api/verify', requestData, (err, res) ->
      return next(err) if err
      parsedResponse = res.split('\n')
      return next(new Error('ReCaptcha response cannot be parsed')) if !parsedResponse
      req.isCaptchaValid = true
      if parsedResponse[0] is false
        req.isCaptchaValid = false
      next()

  # Routes
  app.get '/', (req, res) ->
    res.render 'home',
      user: req.user

  app.get '/login', (req, res) ->
    res.render 'user/login',
      errorMessage: req.flash('error')[0]

  app.post '/login', passport.authenticate('local',
    successRedirect: '/profile'
    failureRedirect: '/login'
    failureFlash:    'message-login-error'
  )
  app.get '/signup', (req, res) ->
    res.render 'user/signup',
      publicKey: config.reCaptcha.publicKey
      hasCaptcha: config.signup.captcha

  signUpMiddlewares = []
  if config.signup.captcha
    signUpMiddlewares.push(validCaptcha)

  app.post '/signup', signUpMiddlewares, (req, res, next) ->
    renderWithError = (errorMessage) ->
      return res.render 'user/signup',
        errorMessage: errorMessage
        publicKey: config.reCaptcha.publicKey
        hasCaptcha: config.signup.captcha

    if config.signup.captcha and req.isCaptchaValid is false
      return renderWithError 'Captcha is not correct'
    User.signup req.body.email, req.body.password, req.locale, (err, user) ->
      return renderWithError('Account already exists') if err
      url = 'http://' + req.host + '/signup/validation?key=' + user.validationKey
      mailer.sendSignupConfirmation req.locale, user.email, url, (err, response) ->
        return next(err) if err
        res.redirect '/signupConfirmation'

  app.get '/signupConfirmation', (req, res) ->
    res.render 'user/signupConfirmation'

  app.get '/signup/validation', (req, res, next) ->
    User.accountValidator req.query.key, (err, user) ->
      return res.redirect '/' if err
      mailer.sendAccountValidatedConfirmation req.locale, user.email, (err, response) ->
        return next(err) if err
        res.redirect '/signupValidation'

  app.get '/signupValidation', (req, res) ->
    res.render 'user/signupValidation'

  app.get '/forgot/password', (req, res, next) ->
    res.render 'user/forgotPassword'

  app.post '/forgot/password', (req, res, next) ->
    User.findOne email: req.body.email, (err, user) ->
      return next(err) if err
      if !user
        return res.render 'user/forgotPassword', email: req.body.email, warningMessage: 'Email was not found'
      user.requestResetPassword (err, user) ->
        return next(err) if err
        url = 'http://' + req.host + '/reset/password?key=' + user.regeneratePasswordKey
        mailer.sendForgotPassword req.locale, user.email, url, (err, response) ->
          return next(err) if err
          res.render 'user/forgotPassword', successMessage: 'We\'ve sent to you a email. Check your mail box.'

  app.get '/reset/password', (req, res, next) ->
    User.findOne regeneratePasswordKey: req.query.key, (err, user) ->
      return next(err) if err
      if !user
        # @todo: detect here if an IP is searching for available key otherwise block this IP for few days
        return res.redirect '/'
      res.render 'user/resetPassword', regeneratePasswordKey: user.regeneratePasswordKey

  app.post '/reset/password', (req, res, next) ->
    User.findOne regeneratePasswordKey: req.body.regeneratePasswordKey, (err, user) ->
      return next(err) if err
      if !user
        # @todo: detect here if an IP is searching for available key otherwise block this IP for few days
        return res.redirect '/'
      if req.body.password
        user.updatePassword req.body.password, (err) ->
          return next(err) if err
          url = 'http://' + req.host + '/forgot/password'
          mailer.sendPasswordReseted req.locale, user.email, url, (err, response) ->
            return next(err) if err
            res.render 'user/resetPassword', successMessage: 'Your password has been updated. Please login again.'

  app.get '/auth/facebook', passport.authenticate('facebook',
    scope: 'email'
  )
  app.get '/auth/facebook/callback', passport.authenticate('facebook',
    failureRedirect: '/login'
  ), (req, res) ->
    res.render 'user/profile',
      user: req.user

  app.get '/profile', (req, res, next) ->
    res.render 'user/profile',
      user: req.user
      languages: config.languages

  app.post '/profile', (req, res, next) ->
    User.update { _id: req.user._id }, req.body, (err) ->
      next(err) if err
      res.redirect '/profile'

  app.post '/profile-picture', (req, res, next) ->
    image.saveUserPicture req.user, req.files.picture, (err, pictureInfo) ->
      return next(err) if err
      baseUrl = ((if config.Upload.sslEnabled then 'https:' else 'http:')) + '//' + req.host + '/'
      res.json files: [
        name: pictureInfo.name
        size: pictureInfo.size
        thumbnailUrl: baseUrl + pictureInfo.thumbnailUrl
        type: pictureInfo.type
        url:  baseUrl + pictureInfo.url
      ]

  app.delete '/profile-picture', (req, res, next) ->
    image.destroyUserPicture req.user

  app.get '/guide', (req, res) ->
    res.render 'guide'

  app.get '/contact', (req, res) ->
    res.render 'contact',
      user: req.user
      publicKey: config.reCaptcha.publicKey
      data: {}

  app.post '/contact', validCaptcha, (req, res, next) ->
    renderWithError = (errors) ->
      res.render 'contact',
        user: req.user
        publicKey: config.reCaptcha.publicKey
        errors: errors
        data: req.body

    if !req.user and req.isCaptchaValid is false
      return renderWithError(captcha: message: 'message-contact-captcha-error')
    contact = new Contact(req.body)
    contact.save (err) ->
      if err
        return renderWithError
          subject: message: err.errors.subject?.message
          message: message: err.errors.message?.message
      return res.redirect '/contact/confirmation' if !req.user
      mailer.sendContactConfirmation req.locale, req.user.email, () ->
        res.redirect '/contact/confirmation'

  app.get '/contact/confirmation', (req, res) ->
    res.render 'contact/confirmation'

  app.get '/logout', (req, res) ->
    req.logout()
    res.redirect '/login'
