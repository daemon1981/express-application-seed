require './bootstrap'

###
Module dependencies.
###
express    = require 'express'
config     = require 'config'
http       = require 'http'
path       = require 'path'
i18n       = require 'i18n'
locale     = require 'locale'
passport   = require 'passport'
flash      = require 'connect-flash'
RedisStore = require('connect-redis')(express)

app = express()

require './passport-bootstrap'

i18n.configure
  locales: config.languages
  directory: __dirname + "/locales"

app.use(locale(config.languages))

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use require("less-middleware")(src: __dirname + "/public")
  app.use express.static(path.join(__dirname, "public"))
  app.use express.static(path.join(__dirname, "uploads"))
  app.use express.cookieParser()
  # app.use express.limit('4M')
  app.use express.bodyParser
    keepExtensions: true
    uploadDir: __dirname + '/uploads'
  app.use express.session({ store: new RedisStore(config.Redis), secret: "keyboard cat" })
  app.use passport.initialize()
  app.use passport.session()
  app.use (req, res, next) ->
    res.locals.locale = i18n.setLocale = req.locale
    if req.user and req.user.language
      res.locals.locale = i18n.setLocale = req.user.language
    if req.query.lang
      supported = new locale.Locales(config.languages)
      res.locals.locale = i18n.setLocale = new locale.Locales(req.query.lang).best(supported)
    next()
  app.locals
    __i: i18n.__
    __n: i18n.__n
    navbar: config.navbar
  app.use express.methodOverride()
  app.use flash()
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

#
#* Error Handling
#
app.use (req, res, next) ->
  res.status 404
  if req.accepts("html")
    res.render "error/404",
      url: req.url

    return
  if req.accepts("json")
    res.send error: "Not found"
    return
  res.type("txt").send "Not found"

app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error/500",
    error: err


require("./routes") app

if module.parent is null
  http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")
else
  module.exports = app
