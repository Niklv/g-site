_ = require 'underscore'
mongoose = require 'mongoose'
gameDB = mongoose.model('games')
DIR = 'partials/app/'

homepage_controller =
  homepage: (req,res)->
    {ctx} = req
    gameDB.pagination 1, 40, ctx, (games)->
      unless games.err?
        ctx.games = _.map games, (game)-> game.toJSON()
        res.render "#{DIR}index", ctx
      else
        ctx.err = games.err
        res.render "#{DIR}index", ctx

  gamepage: (req,res)=>
    {slug} = req.params
    {ctx} = req

    gameDB.pagination 1, 40, ctx, (games)->
      unless games.err?
        ctx.games = _.map games, (game)-> game.toJSON()
        gameDB.getBySlugOrId slug, ctx, (game)->
          unless game.err? or _.isEmpty game
            ctx.gamepage = game.toJSON()
            gameDB.getSimilar slug, 5, ctx, (similar)->
              unless similar.err?
                ctx.gamepage.similar = _.map similar, (game)-> game.toJSON()
                gameDB.getPopular 5, ctx, (popular)->
                  unless popular.err?
                    ctx.gamepage.popular = _.map popular, (game)-> game.toJSON()
                  res.render "#{DIR}index", ctx
              else
                res.render "#{DIR}index", ctx
          else
            res.render "#{DIR}index", ctx
      else
        ctx.err = games.err
        res.render "#{DIR}index", ctx

module.exports = homepage_controller