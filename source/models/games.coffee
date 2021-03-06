url = require 'url'
mongoose = require 'mongoose'
_ = require 'underscore'
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
    trim: true
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
  site: Schema.Types.ObjectId
  pageviews:
    type:Number
    "default": 0
  avg_time:
    type:Number
    "default": 0
  bounce_rate:
    type:Number
    "default": 0


Games.statics.getAllBySiteId = (id, cb)->
  @find {site:id}, cb

Games.statics.getBySlugOrId = (id, ctx, cb)->
  oid = if id?.match "^[0-9A-Fa-f]+$" then new ObjectId id else null
  @findOne {$or:[{slug:id}, {_id: oid}], site:ctx._id}, cb

Games.statics.getSimilar = (id, count, ctx, cb) ->
  @find {site:ctx._id}, null, {limit: count}, cb

Games.statics.getPopular = (count, ctx, cb) ->
  @find {site:ctx._id}, null, {sort: {thumbs_up: -1}, limit: count}, cb

Games.statics.search = (query, ctx, cb)->
  @find {site:ctx._id, title: new RegExp(query, "i")}, null, {limit: 20}, cb

Games.statics.pagination = (page, page_size, ctx, cb)->
  page = page || 0
  page_size = page_size || 40
  @find {site:ctx._id}, null, {sort: {thumbs_up: -1}, skip: (page-1)*page_size, limit: page_size }, cb

Games.statics.countGames = (site_id, ctx, cb)->
  @count {site:site_id}, cb

Games.statics.get = (req, res)->
  {ctx} = req
  {id} = req.params
  {query, page, page_size, popular, similar}= req.query
  key = "#{ctx.locale}/#{ctx.hash}/"
  if id?
    key += id
  key += JSON.stringify req.query
  req.app.mem.get key, (err, val)=>
    if !err and val
      res.json JSON.parse val
    else
      cb = (err, data)->
        unless err
          req.app.mem.set key, JSON.stringify data
          res.json data
        else
          res.json {err}
      if popular?
        #get popular games
        @getPopular popular, ctx, cb
      else if id?
        if similar?
          #get similar games to id
          @getSimilar id, similar, ctx, cb
        else
          #get by id or slug
          @getBySlugOrId id, ctx, cb
      else if query?
        #search by name
        @search query, ctx, cb
      else
        @pagination page, page_size, ctx, cb



Games.statics.put = (req, res)->
  {ctx} = req
  {id} = req.params
  if id? and id.match "^[0-9A-Fa-f]+$"
    oid = new ObjectId id
  thumbsUp = req.query.thumbsUp
  thumbsDown = Boolean req.query.thumbsDown
  changes = {}
  if thumbsUp?
    changes.thumbs_up   = if thumbsUp.localeCompare('true') is 0 then 1 else -1
  else if thumbsDown?
    changes.thumbs_down = if thumbsDown.localeCompare('true') is 0 then 1 else -1
  else
    return res.json err:"unknown action"

  @update {$or:[{slug:id}, {_id: oid}], site:ctx._id}, {$inc: changes}, {multi:false}, (err)->
    unless err?
      res.send success:true
    else
      return res.send err:err

###
i = 0
while i<123
  game_rnd = Math.floor(Math.random() * 100000000)
  picnum = Math.floor(Math.random() * 3) + 1
  g = new gm
  g.title = "Game " + game_rnd
  g.description = "description for game "+game_rnd
  g.slug = "game_slug_" + game_rnd
  g.image_url = '/static/img/thumb150_' + picnum + '.jpg'
  g.swf_url = 'http://www.mousebreaker.com/games/parking/INSKIN__parking-v1.1_Secure.swf'
  g.site = "518f72b56e98bc0200000001"
  console.log g
  g.save (err, it)->
    console.log err
  i++
###

exports.model = mongoose.model 'games', Games
exports.methods = ["get","put"]
