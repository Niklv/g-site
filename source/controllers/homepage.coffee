mongoose = require 'mongoose'
_ = require 'underscore'

homepage_controller =
  homepage: (req,res)->
    console.log "HOMEPAGE"
    {ctx} = req
    mongoose.model('games').find {}, null, {sort: {thumbs_up: -1}, limit:40}, (err, games)->
      unless err?
        ctx.games = _.map games, (game)-> game.toJSON()
        res.render 'layout', ctx
      else
        ctx.err = err
        res.render 'layout', ctx

  gamepage: (req,res)->
    console.log "GAMEPAGE"
    {slug} = req.params
    {ctx} = req
    mongoose.model('games').find {}, null, {limit:40}, (err, games)->
      unless err? or not games?
        ctx.games = _.map games, (game)-> game.toJSON()
        mongoose.model('games').findOne {slug:slug}, (err, game)->
          unless err? or not game?
            ctx.gamepage = game.toJSON()
            res.render 'layout', ctx
          else
            res.render 'layout', ctx
      else
        ctx.err = err
        res.render 'layout', ctx

module.exports = homepage_controller