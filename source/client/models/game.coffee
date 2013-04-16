class Game extends Backbone.Model
  idAttribute: "_id"
  initialize: ()->
    picnum = Math.floor(Math.random() * 3) + 1
    @set "_id", Math.floor(Math.random() * 1000000)
    @set "thumbnail", '/static/img/thumb150_' + picnum + '.jpg'
    @set "name", 'Default game name ' + @get "_id"
    @set "link", 'default-game-link-' + @get "_id"
    @set "swf_link", 'game/swf/link.swf'
    @set "similar", [Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000)]
    return


