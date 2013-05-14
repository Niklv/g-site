_ = require "underscore"
async = require 'async'
mongoose = require 'mongoose'
siteDB = mongoose.model('sites')
gameDB = mongoose.model('games')


static_controller =
  get_file: (req, res)->
    {folder, filename, fingerprint} = req.params
    if filename.length>32
      fingerprint = filename.match /^([0-9a-f]{32})/
    if fingerprint?
      fingerprint = fingerprint[0]
      filename = filename.replace /^([0-9a-f]{32})/, ""
    console.log folder, fingerprint, filename
    res.send 404

module.exports = static_controller