mongoose = require 'mongoose'
_ = require 'underscore'

homepage_controller =
  homepage: (req,res)->
    mongoose.model('games').find {}, (err, games)->
      unless err?
        ctx = games : _.map games, (game)-> game.toJSON()
        res.render 'layout', ctx
      else
        ctx = err:err
        res.render 'layout', ctx


module.exports = homepage_controller