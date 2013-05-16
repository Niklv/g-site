root          = __dirname
i18n          = require 'i18n'
url           = require 'url'
mongoose      = require 'mongoose'
walk          = require 'walk'
fs            = require 'fs'
memjs         = require 'memjs'
crypto        = require 'crypto'
localStrategy = require('passport-local').Strategy


#generate route for RESTful api
exports.createApi = (app, cb)->
  app.models = {}
  walker = walk.walk root + "/models", followLinks:false
  walker.on "names", (root, modelNames)->
    modelNames.forEach (modelName)->
      modelName = modelName.replace /\.[^/.]+$/, ""
      app.models[modelName] = require './models/'+ modelName
  walker.on "end", ()->
    require('./api') app
    console.log "generate api routes    - Ok!"
    app.log.info "generate api routes    - Ok!"
    cb()

#generate locales for i18n
exports.createLocales = (app, cb)->
  app.locales = []
  walker = walk.walk root + "/static/locales", followLinks:false
  walker.on "names", (root, modelNames)->
    modelNames.forEach (localeName)->
      app.locales.push localeName.replace /\.[^/.]+$/, ""
  walker.on "end", ()->
    i18n.configure
      locales: app.locales
      directory: './source/static/locales'
    console.log "search for locales     - Ok!"
    app.log.info "search for locales     - Ok!"
    cb()

#mongo connection
exports.connectToMongo = (app, cb)->
  mongoose.connect process.env.MONGOLAB_URI
  db = mongoose.connection
  db.on 'error', console.error.bind console, 'connection error:'
  db.once 'open', ()->
    console.log "connection to mongo    - Ok!"
    app.log.info "connection to mongo    - Ok!"
    cb()

#memcache
exports.connectToMemcache = (app, cb)->
  app.mem = memjs.Client.create(undefined, expires:60*60)
  console.log "connection to memcache - Ok!"
  app.log.info  "connection to memcache - Ok!"
  cb()

exports.uploadStaticToS3 = (app, cb)->
  console.log "upload static to S3    - Ok!"
  cb()