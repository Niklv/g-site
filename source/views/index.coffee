mongoose = require 'mongoose'
dot = require 'dot'
fs = require 'fs'
_ = require 'underscore'


generateIndex = (req, res)->
  fs.readFile 'source/views/index.dot', (err, tmpl)->
    unless err?
      mongoose.model('games').find {}, (err, games)->
        unless err?
          ctx = games : _.map games, (game)-> game.toJSON()
          tmplfn = dot.template(tmpl.toString(), undefined, {})
          index =  tmplfn ctx
          res.send index
        else
          res.json err
    else
      res.json err

module.exports = generateIndex
