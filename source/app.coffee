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
console.log "DEFINE"
console.log app.stack


startServer = ()->
  app.configure ()->
    console.log "START SERVER"
    console.log app.stack
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
      app:app
      __: i18n.__
      getLocale: i18n.getLocale
      getCatalog: i18n.getCatalog

    #stack
    app.use "/static", express.static './source/static'
    app.use "/", express.static './source/static'
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use express.errorHandler
      dumpExceptions: true,
      showStack: true
    app.use express.cookieParser()
    app.use (req, res, next)->
      #middleware for domain and language detection
      req.domainSettings = req.headers.host
      console.log "_________________________________________"
      console.log req.url
      console.log req.cookies
      #get this grom DB
      defaultLocaleForHost = 'es'
      #
      if req.cookies.lang? && req.cookies.lang in app.locales
        locale = req.cookies.lang
      else
        locale = defaultLocaleForHost
        d = new Date
        res.cookie "lang", locale,
          expires: new Date d.getTime + 1000*24*60*60*1000
          path: '/'
      console.log locale
      i18n.setLocale locale
      next()
    app.use i18n.init
    app.get '/', require('./controllers/homepage').homepage
    app.get '/games/:slug', require('./controllers/homepage').gamepage
    async.auto
      createApi: createApi
      createLocales: createLocales
    , console.log "ok!"
    #port
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
    cb()

#async.auto
#  createApi: createApi
#  createLocales: createLocales
startServer()