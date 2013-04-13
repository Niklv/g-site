class GamesView extends Backbone.View

  initialize: ()->
    _.bindAll(@, "render");
    @el = $ "#games"
    @listenTo @collection, 'add', @appendGame
    @infiniScroll = new Backbone.InfiniScroll @collection, {
      strict: false
      scrollOffset: 600
      error: ()=> #fetch will be error
        i = 0
        while i<20
          @collection.add new Game()
          i++
    }

  render: ()->
    @collection.forEach (game)->
      @appendGame(game)
    return @el

  appendGame: (game, games, options)->
    gameview = new GameView {model : game};
    $(@el).append gameview.render()
    gameview.delegateEvents()
    return @el

  remove: ()->
    @infiniScroll.destroy()
    return Backbone.View.prototype.remove.call @



