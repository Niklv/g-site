$ ()->
  #center games div
  center_games = ()->
    margin = ($(window).width() - $("#games").width() - 10)/2
    $(".content").css "margin-left", margin

  #Init full screen of games
  initFullScreen = ()->
    if $("body").height() > $(window).height() then return
    i = 0
    while i<20
      games.add new Game()
      i++
    center_games()
    setTimeout initFullScreen, 100

  games = new GamesCollection()
  gamesView = new GamesView(games)
  initFullScreen()
  $(document).ready ()->
    $(window).resize center_games

  return