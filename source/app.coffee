#for development
process.env.LOGENTRIES_KEY          = process.env.LOGENTRIES_KEY        || "703440f5-1d7b-4523-885c-76516d11102c"
process.env.NODETIME_ACCOUNT_KEY    = process.env.NODETIME_ACCOUNT_KEY  || "43389b1b19e9d19f93e815650663c4aeb1279b7e"
process.env.MEMCACHIER_SERVERS      = process.env.MEMCACHIER_SERVERS    || "mc2.dev.ec2.memcachier.com:11211"
process.env.MEMCACHIER_USERNAME     = process.env.MEMCACHIER_USERNAME   || "bb3435"
process.env.MEMCACHIER_PASSWORD     = process.env.MEMCACHIER_PASSWORD   || "00b4bfbba300aa89e4bc"
process.env.MONGOLAB_URI            = process.env.MONGOLAB_URI          || 'mongodb://gsite_app:temp_passw0rd@ds041327.mongolab.com:41327/heroku_app14575890'
process.env.FILEPICKER_API_KEY      = process.env.FILEPICKER_API_KEY    || 'AgykdYRA2RAmToPuJhQosz'
process.env.FILEPICKER_API_SECRET   = process.env.FILEPICKER_API_SECRET || 'F6FYMAT5ZBFUVJL67O4MX5G52U'
process.env.AWS_ACCESS_KEY_ID       = process.env.AWS_ACCESS_KEY_ID     || 'AKIAITI4VR6ZZFFCJ5FA'
process.env.AWS_SECRET_ACCESS_KEY   = process.env.AWS_SECRET_ACCESS_KEY || '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'
process.env.AWS_CLOUDFRONT_IMG      = process.env.AWS_CLOUDFRONT_IMG    || 'd1zjm5k21y5rcp.cloudfront.net'
process.env.AWS_CLOUDFRONT_STATIC   = process.env.AWS_CLOUDFRONT_STATIC || 'dsogyhci03djz.cloudfront.net'
process.env.AWS_STORAGE_BUCKET_NAME = process.env.AWS_STORAGE_BUCKET_NAME || 'gsites-static'
process.env.AWS_STORAGE_BUCKET_NAME_IMG = process.env.AWS_STORAGE_BUCKET_NAME_IMG || 'gsites-img'
process.env.AWS_STORAGE_BUCKET_NAME_STATIC = process.env.AWS_STORAGE_BUCKET_NAME_STATIC || 'gsites-static'


#profiler
if process.env.NODETIME_ACCOUNT_KEY
  require('nodetime').profile
    accountKey: process.env.NODETIME_ACCOUNT_KEY
    appName: 'g-sites'

#requires
root          = __dirname
express       = require 'express'
i18n          = require 'i18n'
mongoose      = require 'mongoose'
dot           = require 'express-dot'
async         = require 'async'
_             = require 'underscore'
passport      = require 'passport'
crypto        = require 'crypto'
logentries    = require 'node-logentries'
localStrategy = require('passport-local').Strategy


app = express()

#register models
sites        = require './models/sites'
games        = require './models/games'

#controllers
admin        = require './controllers/admin'
index        = require './controllers/index'
static_files = require './controllers/static'

#logger
app.log = logentries.logger token: process.env.LOGENTRIES_KEY
app.log.info "====================================="
app.log.info "====================================="
app.log.info "Start server!"

startServer = ()->
  app.configure ()->
    #dot
    app.set 'views', './source/views'
    app.set 'view engine', 'dot'
    app.engine 'dot', dot.__express

    #stack
    app.use express.compress()
    app.use "/public", express.static './source/public', {maxAge: 86400000}
    app.use "/static", express.static './source/public', {maxAge: 86400000}
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
      req.ctx.env = process.env
      req.ctx.file = app.file
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
              app.log.warning "domain #{req.headers.host} not found in sites db"
              res.send 404


    app.use (req, res, next)->
      req.ctx.locale = req.ctx.language
      #if site suspended
      if req.ctx.enable or (req.url.match "^\/admin")? or (req.user is 'admin' and (req.url.match "^\/api")?)
        next()
      else
        res.send 404

    async.auto
      api:        (cb) -> require('./onstart').createApi app, cb
      locales:    (cb) -> require('./onstart').createLocales app, cb
      mongo:      (cb) -> require('./onstart').connectToMongo app, cb
      memcache:   (cb) -> require('./onstart').connectToMemcache app, cb
      grunt:      (cb) -> require('./onstart').runGrunt app, cb
      uploadToS3: ['grunt', (cb) -> require('./onstart').uploadStaticToS3 app, cb ]
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
  #app.get '/public/css/site-settings.css', index.site_css
  #app.get '/games/:slug', index.gamepage
  app.get '/', isInCache, index.homepage
  app.get '/public/css/site-settings.css', isInCache, index.site_css
  app.get '/games/:slug', isInCache, index.gamepage
  #app.get '/static/:folder/:filename', isInCache, static_files.get_file




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