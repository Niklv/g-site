root = __dirname
express = require 'express'
mongoose = require 'mongoose'
games = require './server/games'




mongoose.connect 'mongodb://gsite_app:temp_passw0rd@ds041327.mongolab.com:41327/heroku_app14575890'
db = mongoose.connection
db.on 'error', console.error.bind console, 'connection error:'
db.once 'open', ()->
  console.log "connection to mongo - Ok!"


app = express.createServer()



#app.get "/", (req, res)->
#  res.redirect "/index.html"



app.configure ()->
  app.use express.methodOverride()
  app.use express.bodyParser()
  app.use express.static __dirname + '/source'
  app.use express.errorHandler
    dumpExceptions: true,
    showStack: true
  app.use app.router



app.get '/games/:slug', games.getBySlug




port = process.env.PORT || 5000
app.listen port, ()->
  console.log "Listening on " + port