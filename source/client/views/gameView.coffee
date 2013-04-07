class GameView extends Backbone.View
  tagName: "div"
  className: "game"
  render: ()->
    this.el.innerHTML = this.model.get 'name'

#gameView = new GameView()

