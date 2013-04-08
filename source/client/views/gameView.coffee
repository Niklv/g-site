class GameView extends Backbone.View
  tagName: "div"
  className: "game"
  initialize: (game)->
    this.model = game
  render: ()->
    $(this.el).append "<img class='thumb' src='#{this.model.thumbnail}'><div class='name'>#{this.model.name}</div>"
    return this.el



