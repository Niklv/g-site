admin_controller =
  adminpage: (req,res)->
    console.log "ADMINPAAAGE!"
    res.render 'adminpage', {}


module.exports = admin_controller