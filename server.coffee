express = require 'express';

app = express.createServer express.logger()

app.get "/", (req, res)->
  res.redirect "/index.html"

app.configure ()->
  app.use express.methodOverride()
  app.use express.bodyParser()
  app.use express.static __dirname + '/source'
  app.use express.errorHandler
    dumpExceptions: true,
    showStack: true
  app.use app.router

port = process.env.PORT || 5000
app.listen port, ()->
  console.log "Listening on " + port
