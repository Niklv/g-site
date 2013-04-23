url = require 'url'
mongoose = require 'mongoose'
Schema = require '../rest'
ObjectId = mongoose.Types.ObjectId;

Games = new Schema
  title:
    type: String
    required: true
  description: String
  slug:
    type: String
    required: true
  image_url:
    type: String
    required: true
  swf_url:
    type: String
    required: true
  created_on:
    type: Date
    "default": Date.now
  updated_on:
    type: Date
    "default": Date.now
  thumbs_up:
    type:Number
    "default": 0
  thumbs_down:
    type:Number
    "default": 0




Games.statics.get = (req, res)->
  {id} = req.params
  page = req.query.page || 0
  page_size = req.query.page_size || 40
  if id?
    if id.match "^[0-9A-Fa-f]+$"
      oid = new ObjectId id
    else
      oid = null
    @findOne {$or:[{slug:id}, {_id: oid}]}, (err, game)=>
      unless err?
        if game?
          res.json game
        else
          res.json err:"game not found"
      else
        res.json err:err
  else
    #pagination
    @find {}, null, { skip: (page-1)*page_size, limit: page_size }, (err, games)=>
      unless err?
        if games?
          res.json games
        else
          res.json err:"games not found"
      else
        res.json err:err

###
gm = (mongoose.model 'games', Games)

i = 0
while i<100
  game_rnd = Math.floor(Math.random() * 100000000)
  picnum = Math.floor(Math.random() * 3) + 1
  g = new gm
  g.title = "Game " + game_rnd
  g.description = "description for game "+game_rnd
  g.slug = "game_slug_" + game_rnd
  g.image_url = '/static/img/thumb150_' + picnum + '.jpg'
  g.swf_url = 'http://www.mousebreaker.com/games/parking/INSKIN__parking-v1.1_Secure.swf'
  console.log g
  g.save (err, it)->
    console.log err
  i++
###


exports.model = mongoose.model 'games', Games
exports.methods = ["get","post","delete","put","patch"]
