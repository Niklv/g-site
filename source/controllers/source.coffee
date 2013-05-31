fs = require 'fs'
crypto = require 'crypto'
request = require 'request'
http = require 'http'
googleapis = require 'googleapis'





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

  collect_data: ()->
    authorize (err, data)->
      console.log err
      console.log data




authHeader =
  alg: 'RS256'
  typ: 'JWT'

authClaimSet =
  iss: process.env.GA_SERVICE_EMAIL
  scope: 'https://www.googleapis.com/auth/analytics.readonly'
  aud: 'https://accounts.google.com/o/oauth2/token'

SIGNATURE_ALGORITHM = 'RSA-SHA256'
SIGNATURE_ENCODE_METHOD = 'base64'
gaKey = null


authorize = (cb)->
  now = parseInt Date.now() / 1000, 10
  signatureKey = readPrivateKey()

  #Setup time values
  authClaimSet.iat = now
  authClaimSet.exp = now + 60

  console.log authClaimSet
  #Setup JWT source
  signatureInput = base64Encode(authHeader) + '.' + base64Encode authClaimSet

  #Generate JWT
  cipher = crypto.createSign 'RSA-SHA256'
  cipher.update signatureInput
  signature = cipher.sign signatureKey, 'base64'
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
  unless gaKey
    gaKey = fs.readFileSync process.env.GA_KEY_PATH, 'utf8'
  gaKey


module.exports = source_controller