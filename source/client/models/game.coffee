class Game extends Backbone.Model
  initialize: ()->
    picnum = Math.floor(Math.random() * 3) + 1
    @set "thumbnail", '/static/img/thumb150_' + picnum + '.jpg'
    @set "name", 'Default game name'
    @set "link", 'default-game-link'
    @set "swf_link", 'game/swf/link.swf'
    return


