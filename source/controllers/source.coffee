_ = require 'underscore'
fs = require 'fs'
crypto = require 'crypto'
request = require 'request'
qs = require 'querystring'
http = require 'http'
googleapis = require 'googleapis'
mongoose = require 'mongoose'
sites = mongoose.model 'sites'
games = mongoose.model 'games'





source_controller =
  process_image: (img_url, cb)->
    job_data =
      "application_id" : process.env.BLITLINE_APPLICATION_ID
      "src" : "http://www.google.com/logos/2011/yokoyama11-hp.jpg"
      "functions" : [
        "name":"resize_to_fill"
        "params":
          "width":50
          "height":50
        "save" :
          "image_identifier" : "MY_CLIENT_ID"
          "s3_destination" :
            "bucket" : process.env.AWS_STORAGE_BUCKET_NAME_IMG
            "key" : "test_image.jpg"
            "headers" :
              "x-amz-acl" :"public-read"
        ]

    options =
      host: 'api.blitline.com'
      port: 80
      method:"POST"
      path: '/job'

    req = http.request options, (res)->
      res.on "data", (chunk)->
        console.log "Data=" + chunk
      res.on 'error', (e)->
        console.log "Got error: " + e.message

    req.write "json=" + JSON.stringify job_data
    req.end()

  update_game_analytics: ()->
    authorize (err, data)->
      unless err
        #Query the number of total visits for a month
        requestConfig =
          'ids': 'ga:73030585'
          'start-date': '2013-02-01'
          'end-date': '2013-06-01'
          'metrics': 'ga:pageviews,ga:timeOnPage,ga:bounces'
          'dimensions': 'ga:hostname,ga:pagePath'

        request
          method: 'GET'
          headers:
            'Authorization': 'Bearer ' + data.access_token
          uri: 'https://www.googleapis.com/analytics/v3/data/ga?' + qs.stringify requestConfig
        , (err, res, body)->
          data = JSON.parse body
          if data.error
            console.log data.error.errors
          else
            domains = _.uniq data.rows, false, (it)->it[0]
            domains = _.map domains, (it) -> it[0]
            _.each domains, (domainName)->
              sites.getByDomain (domainName.replace "www.", ""), (err, site)->
                unless err
                  games.getAllBySiteId site._id, (err, games)->
                    unless err
                      _.each games, (game)->
                        _.each data.rows, (stat)->
                          if (stat[0] is domainName) and (stat[1] is "/games/#{game.slug}")
                            game.pageviews = stat[2]
                            game.avg_time = stat[3]
                            game.bounce_rate = stat[4]
                            game.save()
                    else
                      console.log err
                else
                  console.log err
      else
        console.log err







authorize = (cb)->
  now = parseInt Date.now() / 1000, 10

  authHeader =
    alg: 'RS256'
    typ: 'JWT'

  authClaimSet =
    iss  : process.env.GA_SERVICE_EMAIL
    scope: 'https://www.googleapis.com/auth/analytics.readonly'
    aud  : 'https://accounts.google.com/o/oauth2/token'
    iat  : now
    exp  : now + 60

  #Setup JWT source
  signatureInput = base64Encode(authHeader) + '.' + base64Encode authClaimSet

  #Generate JWT
  cipher = crypto.createSign 'RSA-SHA256'
  cipher.update signatureInput
  signature = cipher.sign readPrivateKey(), 'base64'
  jwt = signatureInput + '.' + urlEscape signature

  #Send request to authorize this application
  request
    method: 'POST'
    headers:
      'Content-Type': 'application/x-www-form-urlencoded'
    uri: 'https://accounts.google.com/o/oauth2/token'
    body: 'grant_type=' + escape('urn:ietf:params:oauth:grant-type:jwt-bearer') +
    '&assertion=' + jwt
  , (err, res, body)=>
    if err
      console.log err
      cb new Error err
    else
      gaResult = JSON.parse body
      if gaResult.error
        cb new Error gaResult.error
      else
        cb null, gaResult

urlEscape = (source)->
  source.replace(/\+/g, '-').replace(/\//g, '_').replace /\=+$/, ''

base64Encode = (obj)->
  encoded = new Buffer(JSON.stringify(obj), 'utf8').toString 'base64'
  urlEscape encoded

readPrivateKey = ->
  fs.readFileSync process.env.GA_KEY_PATH, 'utf8'


module.exports = source_controller