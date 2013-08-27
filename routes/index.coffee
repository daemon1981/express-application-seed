passport = require "passport"
config   = require "config"
request  = require "request"

User     = require("../model/user")
Contact  = require("../model/contact")
Mailer   = require("../lib/mailer")
Image    = require("../lib/image")

image  = new Image(config.Upload)
mailer = new Mailer()

module.exports = (app) ->
  # Helpers
  isAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
      next()
    else
      res.redirect "/login"

  userExist = (req, res, next) ->
    User.count
      username: req.body.username
    , (err, count) ->
      if count is 0
        next()
      else
        res.redirect "/signup"

  # Routes
  app.get "/", (req, res) ->
    if req.isAuthenticated()
      res.render "home",
        user: req.user

    else
      res.render "home",
        user: null

  app.get "/login", (req, res) ->
    res.render "user/login"

  app.post "/login", passport.authenticate("local",
    successRedirect: "/profile"
    failureRedirect: "/login"
  )
  app.get "/signup", (req, res) ->
    res.render "user/signup"

  app.post "/signup", userExist, (req, res, next) ->
    User.signup req.body.email, req.body.password, (err, user) ->
      return res.render("user/signup", errorMessage: 'Account already exists') if err
      url = 'http://' + req.host + '/signup/validation?key=' + user.validationKey
      mailer.sendSignupConfirmation user.email, url, (err, response) ->
        return next(err) if err
        res.redirect "/signupConfirmation"

  app.get "/signupConfirmation", (req, res) ->
    res.render "user/signupConfirmation"

  app.get "/signup/validation", (req, res, next) ->
    User.accountValidator req.query.key, (err, user) ->
      return res.redirect "/" if err
      mailer.sendAccountValidatedConfirmation user.email, (err, response) ->
        return next(err) if err
        res.redirect "/signupValidation"

  app.get "/signupValidation", (req, res) ->
    res.render "user/signupValidation"

  app.get "/forgot/password", (req, res, next) ->
    res.render "user/forgotPassword"

  app.post "/forgot/password", (req, res, next) ->
    User.findOne email: req.body.email, (err, user) ->
      return next(err) if err
      if !user
        return res.render "user/forgotPassword", email: req.body.email, warningMessage: 'Email was not found'
      user.requestResetPassword (err, user) ->
        return next(err) if err
        url = 'http://' + req.host + '/reset/password?key=' + user.regeneratePasswordKey
        mailer.sendForgotPassword user.email, url, (err, response) ->
          return next(err) if err
          res.render "user/forgotPassword", successMessage: 'We\'ve sent to you a email. Check your mail box.'

  app.get "/reset/password", (req, res, next) ->
    User.findOne regeneratePasswordKey: req.query.key, (err, user) ->
      return next(err) if err
      if !user
        # @todo: detect here if an IP is searching for available key otherwise block this IP for few days
        return res.redirect "/"
      res.render "user/resetPassword", regeneratePasswordKey: user.regeneratePasswordKey

  app.post "/reset/password", (req, res, next) ->
    User.findOne regeneratePasswordKey: req.body.regeneratePasswordKey, (err, user) ->
      return next(err) if err
      if !user
        # @todo: detect here if an IP is searching for available key otherwise block this IP for few days
        return res.redirect "/"
      if req.body.password
        user.updatePassword req.body.password, (err) ->
          return next(err) if err
          url = 'http://' + req.host + '/forgot/password'
          mailer.sendPasswordReseted user.email, url, (err, response) ->
            return next(err) if err
            res.render "user/resetPassword", successMessage: 'Your password has been updated. Please login again.'

  app.get "/auth/facebook", passport.authenticate("facebook",
    scope: "email"
  )
  app.get "/auth/facebook/callback", passport.authenticate("facebook",
    failureRedirect: "/login"
  ), (req, res) ->
    res.render "user/profile",
      user: req.user

  app.get "/profile", isAuthenticated, (req, res, next) ->
    res.render "user/profile",
      user: req.user

  app.post "/profile", isAuthenticated, (req, res, next) ->
    User.update { _id: req.user._id }, req.body, (err) ->
      next(err) if err
      res.redirect "/profile"

  app.post "/profile-picture", isAuthenticated, (req, res, next) ->
    image.saveUserPicture req.user, req.files.picture, (err, pictureInfo) ->
      return next(err) if err
      baseUrl = ((if config.Upload.sslEnabled then "https:" else "http:")) + "//" + req.host + '/'
      res.json files: [
        name: pictureInfo.name
        size: pictureInfo.size
        thumbnailUrl: baseUrl + pictureInfo.thumbnailUrl
        type: pictureInfo.type
        url:  baseUrl + pictureInfo.url
      ]

  app.delete "/profile-picture", isAuthenticated, (req, res, next) ->
    image.destroyUserPicture req.user

  app.get "/guide", (req, res) ->
    res.render "guide"

  app.get "/contact", (req, res) ->
    res.render "contact",
      user: req.user
      publicKey: config.reCaptcha.publicKey

  app.post "/contact", (req, res, next) ->
    renderWithError = (errorMessage) ->
      res.render "contact",
        user: req.user
        publicKey: config.reCaptcha.publicKey
        errorMessage: errorMessage

    createContact = (email) ->
      contact = new Contact(req.body)
      contact.save (err) ->
        return renderWithError 'An error in the form' if err
        mailer.sendContactConfirmation email, () ->
          res.redirect "/contact/confirmation"

    if req.isAuthenticated()
      createContact req.user.email
    else
      requestData =
        privatekey: config.reCaptcha.privateKey
        remoteip:   req.ip
        challenge:  req.body.recaptcha_challenge_field
        response:   req.body.recaptcha_response_field
      request.post 'http://www.google.com/recaptcha/api/verify', requestData, (err, res) ->
        return next(err) if err
        parsedResponse = res.split('\n')
        return next(new Error('ReCaptcha response cannot be parsed')) if !parsedResponse
        if parsedResponse[0] is false
          return renderWithError 'Captcha is not correct' if err
        createContact req.body.email

  app.get "/contact/confirmation", (req, res) ->
    res.render "contact/confirmation"

  app.get "/logout", (req, res) ->
    req.logout()
    res.redirect "/login"
