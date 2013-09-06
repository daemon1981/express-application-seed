i18n       = require 'i18n'
locale     = require 'locale'
_          = require('underscore')._

exports.checkAuthentication = (publicPathes, redirectPath) ->
  return (req, res, next) ->
    if _.indexOf(publicPathes, req.path) is -1 and !req.isAuthenticated()
      res.redirect redirectPath
    else
      next()

exports.setLocale  = (languages) ->
  supported = new locale.Locales(languages)

  return (req, res, next) ->
    currentLocal = new locale.Locales(req.locale).best(supported)
    if req.user and req.user.language
      currentLocal = req.user.language
    if req.query.lang
      currentLocal = new locale.Locales(req.query.lang).best(supported)

    # set locale for views
    res.locals.locale = currentLocal
    # set locale in request
    req.locale = currentLocal
    # set locale for i18n
    i18n.setLocale currentLocal
    next()
