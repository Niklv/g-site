$ ()->
  games = new GamesCollection()
  gamesView = new GamesView(games)
  gamesView.render()
  i =0
  while i<30
    games.add new Game()
    i++



  #App = new AppView()
  #App.listenTo games, 'add', App.addOne()
  #App.render()
  return