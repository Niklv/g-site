class GamesCollection extends Backbone.Collection
  model : Game
  url: '/games'
  ###
  fetch : ()->
    console.log "fetch!"
    i =0
    while i<50
      this.add new Game()
      i++
    parm = Backbone.Collection.prototype.fetch.call this
    return parm
  ###

  #get from server by name
  search: (query)->
    return _.map @models, (item)->
      item.toString = ()->
        JSON.stringify @
      item.toLowerCase = ()->
        @name.toLowerCase()
      item.indexOf = (string) ->
        String::indexOf.apply @name, arguments
      item.replace = (string) ->
        String::replace.apply @name, arguments
      return item