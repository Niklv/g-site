root      = __dirname
express   = require 'express'
i18n      = require 'i18n'
url       = require 'url'
mongoose  = require 'mongoose'
walk      = require 'walk'
fs        = require 'fs'
dot       = require 'express-dot'
async     = require 'async'
_         = require 'underscore'
games     = require './models/games'


app = express()

startServer = ()->
  app.configure ()->
    #dot
    app.engine 'dot', dot.__express
    app.set 'views', './source/views'
    app.set 'view engine', 'dot'

    #stack
    app.use "/static", express.static './source/static'
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use express.errorHandler
      dumpExceptions: true,
      showStack: true
    app.use express.cookieParser()
    app.use (req, res, next)->
      #######LOGGING#######
      #console.log "_________________________________________"
      console.log req.url
      #console.log req.cookies
      #####################
      ctx = {}
      ctx.locales = app.locales
      ctx.domain = {}
      ctx.domain.host = req.headers.host
      ctx.__ = i18n.__
      ctx.domain.defaultLocale = 'es'
      if req.cookies.lang in ctx.locales
        ctx.locale = req.cookies.lang
      else if i18n.getLocale req in ctx.locales
        ctx.locale = i18n.getLocale req
      else
        ctx.locale = ctx.domain.defaultLocale
      req.ctx = ctx
      next()

    app.use i18n.init
    app.get '/', require('./controllers/homepage').homepage
    app.get '/games/:slug', require('./controllers/homepage').gamepage
    async.auto
      createApi: createApi
      createLocales: createLocales
      mongo: connectToMongo
    , ()->
      port = process.env.PORT || 5000
      app.listen port, ()->
        console.log "Listening on " + port

      console.log app.stack




#generate route for RESTful api
createApi = (cb)->
  app.models = {}
  walker = walk.walk root + "/models", followLinks:false
  walker.on "names", (root, modelNames)->
    modelNames.forEach (modelName)->
      modelName = modelName.replace /\.[^/.]+$/, ""
      app.models[modelName] = require './models/'+ modelName
  walker.on "end", ()->
    require('./api') app
    console.log "generate api routes - Ok!"
    cb()

#generate locales for i18n
createLocales = (cb)->
  app.locales = []
  walker = walk.walk root + "/static/locales", followLinks:false
  walker.on "names", (root, modelNames)->
    modelNames.forEach (localeName)->
      app.locales.push localeName.replace /\.[^/.]+$/, ""
  walker.on "end", ()->
    i18n.configure
      locales: app.locales
      directory: './source/static/locales'
    console.log "search for locales - Ok!"
    cb()

#mongo connection
connectToMongo = (cb)->
  mongoose.connect 'mongodb://gsite_app:temp_passw0rd@ds041327.mongolab.com:41327/heroku_app14575890'
  db = mongoose.connection
  db.on 'error', console.error.bind console, 'connection error:'
  db.once 'open', ()->
    console.log "connection to mongo - Ok!"
    cb()


startServer()