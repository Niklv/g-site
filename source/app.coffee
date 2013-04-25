root      = __dirname
express   = require 'express'
i18n      = require 'i18n'
url       = require 'url'
mongoose  = require 'mongoose'
walk      = require 'walk'
fs        = require 'fs'
dot       = require 'express-dot'
_         = require 'underscore'
games     = require './models/games'


app = express()

startServer = ()->
  app.configure ()->
    #mongo connection
    mongoose.connect 'mongodb://gsite_app:temp_passw0rd@ds041327.mongolab.com:41327/heroku_app14575890'
    db = mongoose.connection
    db.on 'error', console.error.bind console, 'connection error:'
    db.once 'open', ()->
      console.log "connection to mongo - Ok!"

    #dot
    app.engine 'dot', dot.__express
    app.set 'views', './source/views'
    app.set 'view engine', 'dot'
    dot.setGlobals
      __: i18n.__

    #i18n
    i18n.configure
      locales: ['en', 'es', 'ru']
      directory: './source/static/locales'


    #stack
    app.use "/static", express.static './source/static'
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use express.errorHandler
      dumpExceptions: true,
      showStack: true
    app.use express.cookieParser()
    app.use (req, res, next)->
      #middleware for domain and language detection
      req.domainSettings = req.headers.host
      defaultLocaleForHost = 'es'
      console.log req.cookies
      if req.cookies.lang?
        locale = req.cookies.lang
      else
        locale = defaultLocaleForHost
        res.cookie "lang", locale, maxAge: 1000*24*60*60*1000
      i18n.setLocale locale
      next()
    app.use i18n.init
    #route
    app.use '/', require('./controllers/homepage').homepage
    app.use '/games/:slug', require('./controllers/homepage').gamepage




    #port
    port = process.env.PORT || 5000
    app.listen port, ()->
      console.log "Listening on " + port

    console.log app.stack


#generate route for RESTful api
app.models = {}
walker = walk.walk root + "/models", followLinks:false
walker.on "names", (root, modelNames)->
  modelNames.forEach (modelName)->
    modelName = modelName.replace /\.[^/.]+$/, ""
    app.models[modelName] = require './models/'+ modelName

walker.on "end", ()->
  require('./api') app
  startServer()