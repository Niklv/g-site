mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

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

Games.statics.getBySlug = (req, res)->
  {slug} = req.params
  console.log slug
  console.log @
  if slug?
    @findOne {slug:slug}, (err, game)->
      if game? and not err?
        res game
      else
        res null
  else
    res null

GamesModel = mongoose.model 'games', Games


#GamesModel.findOne {"slug":"simple_game_name_1"}, (err, item)->
#  console.log item, err



module.exports = GamesModel