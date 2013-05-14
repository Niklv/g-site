#for development
process.env.NODETIME_ACCOUNT_KEY = process.env.NODETIME_ACCOUNT_KEY || "43389b1b19e9d19f93e815650663c4aeb1279b7e"
process.env.MEMCACHIER_SERVERS   = process.env.MEMCACHIER_SERVERS   || "mc2.dev.ec2.memcachier.com:11211"
process.env.MEMCACHIER_USERNAME  = process.env.MEMCACHIER_USERNAME  || "bb3435"
process.env.MEMCACHIER_PASSWORD  = process.env.MEMCACHIER_PASSWORD  || "00b4bfbba300aa89e4bc"
process.env.MONGOLAB_URI         = process.env.MONGOLAB_URI         || 'mongodb://gsite_app:temp_passw0rd@ds041327.mongolab.com:41327/heroku_app14575890'

#profiler
if process.env.NODETIME_ACCOUNT_KEY
  require('nodetime').profile
    accountKey: process.env.NODETIME_ACCOUNT_KEY
    appName: 'g-sites'

#requires
root          = __dirname
express       = require 'express'
i18n          = require 'i18n'
url           = require 'url'
mongoose      = require 'mongoose'
walk          = require 'walk'
fs            = require 'fs'
dot           = require 'express-dot'
async         = require 'async'
_             = require 'underscore'
passport      = require 'passport'
memjs         = require 'memjs'
crypto        = require 'crypto'
logentries    = require 'node-logentries'
localStrategy = require('passport-local').Strategy


#register models
sites        = require './models/sites'
games        = require './models/games'

#controllers
admin        = require './controllers/admin'
index        = require './controllers/index'
static_files = require './controllers/static'

#logger
log = logentries.logger token:'703440f5-1d7b-4523-885c-76516d11102c'

app = express()
startServer = ()->
  app.configure ()->
    #dot
    app.set 'views', './source/views'
    app.set 'view engine', 'dot'
    app.engine 'dot', dot.__express

    #stack
    app.use express.compress()
    #app.use "/static", express.static './source/static', {maxAge: 86400000}
    app.use express.cookieParser()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.errorHandler
      dumpExceptions: true,
      showStack: true
    app.use express.session secret:'super-puper-secret-key'
    app.use passport.initialize()
    app.use passport.session()
    app.use i18n.init
    app.use (req, res, next)->
      #######LOGGING#######
      #console.log req.url
      #####################
      req.ctx = {}
      req.ctx.__ = i18n.__
      req.ctx.locales = app.locales
      req.ctx.api = '/api/v1.alpha'
      domain = req.headers.host.replace(/^www\./, "")#.replace /^search\./, ""
      domain = domain.replace "localhost:5000", "g-sites.herokuapp.com" #for development
      key = domain
      app.mem.get key, (err, val)->
        if !err and val
          _.extend req.ctx, JSON.parse val
          next()
        else
          mongoose.model('sites').getByDomain domain, (err, domain)->
            if !err? and domain?
              domain = domain.toJSON()
              domain.hash = crypto.createHash('md5').update(JSON.stringify domain ).digest "hex"
              _.extend req.ctx, domain
              app.mem.set key, JSON.stringify domain
              next()
            else
              log.warning "domain #{req.headers.host} not found in sites db"
              res.send 404


    app.use (req, res, next)->
      req.ctx.locale = req.ctx.language
      #if site suspended
      if req.ctx.enable or (req.url.match "^\/admin")? or (req.user is 'admin' and (req.url.match "^\/api")?)
        next()
      else
        res.send 404


    async.auto
      api: createApi
      locales: createLocales
      mongo: connectToMongo
      memcache: connectToMemcache
    , ()->
      port = process.env.PORT || 5000
      app.listen port, ()->
        console.log "Listening on " + port

  app.post '/admin/login', passport.authenticate('local'), (req, res)->res.redirect '/admin/'
  app.get '/admin/', ensureAuthenticated, admin.sites
  app.get '/admin', (req, res)-> res.redirect '/admin/'
  app.get '/admin/site/:site', ensureAuthenticated, admin.site_settings
  app.get '/admin/ads/', ensureAuthenticated, admin.ads_settings
  app.get '/admin/status/', ensureAuthenticated, admin.status
  app.get '/admin/login', redirectIfAuthenticated, admin.login
  app.get '/admin/logout', admin.logout

  #app.get '/', index.homepage
  #app.get '/static/css/site-settings.css', index.site_css
  #app.get '/games/:slug', index.gamepage
  app.get '/', isInCache, index.homepage
  app.get '/static/css/site-settings.css', isInCache, index.site_css
  app.get '/static/:folder/:filename', isInCache, static_files.get_file
  app.get '/games/:slug', isInCache, index.gamepage








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
    log.info "generate api routes    - Ok!"
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
    log.info "search for locales     - Ok!"
    cb()

#mongo connection
connectToMongo = (cb)=>
  mongoose.connect process.env.MONGOLAB_URI
  db = mongoose.connection
  db.on 'error', console.error.bind console, 'connection error:'
  db.once 'open', ()->
    log.info "connection to mongo    - Ok!"
    cb()

#memcache
connectToMemcache = (cb)=>
  app.mem = memjs.Client.create(undefined, expires:60*60)
  log.info  "connection to memcache - Ok!"
  cb()








#Auth
passport.use new localStrategy (username, password, done)->
  if username is 'admin'
    if password is 'admin'
      return done null, username
    else
      return done null, false, message: 'Incorrect password.'
  else
    return done null, false, message: 'Incorrect username.'

passport.serializeUser (user, done)->
  done null, user

passport.deserializeUser (id, done)->
  done null, id







#Other middleware
ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect '/admin/login'

redirectIfAuthenticated = (req, res, next)->
  unless req.isAuthenticated()
    return next()
  res.redirect '/admin/'

isInCache = (req, res, next)->
  app.mem.get "#{req.ctx.locale}/#{req.ctx.hash}#{req.url}", (err, val)->
    if !err and val
      extension = req.url.split '.'
      if extension?[extension.length-1] is 'css'
        res.set 'Content-Type', 'text/css'
      else
        res.set 'Content-Type', 'text/html'
      res.send val
    else
      next()

startServer()