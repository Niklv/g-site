class AppView extends Backbone.View
  el: $ "div#appView"
  initialize: ()->
    this.el = $ "div#appView"
    return
  render: ()->
    #this.el.append '<h1>name</h1>'
    #this.el.css "color", "red"
    return
  addOne: ()->
    console.log "ADDONE"



