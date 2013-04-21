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
  {page, size} = req.query
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
    #do there pagination
    res.json err:"wrong game slug"

exports.model = mongoose.model 'games', Games
exports.methods = ["get","post","delete","put","patch"]
