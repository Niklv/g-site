class Game extends Backbone.Model
  urlRoot: '/api/v1.alpha/games'
  idAttribute: "_id"
  initialize: ()->
    picnum = Math.floor(Math.random() * 3) + 1

    @set "_id", Math.floor(Math.random() * 1000000)
    @set "image_url", '/static/img/thumb150_' + picnum + '.jpg'
    @set "title", 'This is long default game name with number ' + @get "_id"
    @set "slug", 'default-game-link-' + @get "_id"
    @set "swf_url", 'http://www.mousebreaker.com/games/parking/INSKIN__parking-v1.1_Secure.swf'
    @set "similar", [Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000)]
    return

  #methed for development
  twin: (id)->
    @set "_id", id
    @set "title", 'This is long default game name with number ' + @get "_id"
    @set "slug", 'default-game-link-' + @get "_id"
    @set "swf_url", 'http://www.mousebreaker.com/games/parking/INSKIN__parking-v1.1_Secure.swf'
    @set "similar", [Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000)]


