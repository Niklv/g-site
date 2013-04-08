$ ()->
  games = new GamesCollection()
  App = new AppView()
  App.listenTo games, 'add', App.render()
  App.render()
  return