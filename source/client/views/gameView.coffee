class GameView extends Backbone.View
  tagName: "div"
  className: "game"
  initialize: ()->
    this.listenTo this.model, "change", this.render
  render: ()->
    this.el.innerHTML = this.model.get 'name'

