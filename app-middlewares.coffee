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
  return (req, res, next) ->
    currentLocal = req.locale
    if req.user and req.user.language
      currentLocal = req.user.language
    if req.query.lang
      supported = new locale.Locales(languages)
      currentLocal = new locale.Locales(req.query.lang).best(supported)
    res.locals.locale = currentLocal
    i18n.setLocale currentLocal
    next()
