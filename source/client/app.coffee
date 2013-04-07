$ ()->
  games = new GamesCollection()
  console.log games.toJSON()
  console.log games.get(0).toJSON()
  App = new AppView()
  App.listenTo games, 'add', App.render()
  App.render()
  return