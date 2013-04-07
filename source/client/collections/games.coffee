class GamesCollection extends Backbone.Collection
  model : Game
  initialize: ()->
    i =0
    while i<100
      this.add new Game()
      i++
    return

