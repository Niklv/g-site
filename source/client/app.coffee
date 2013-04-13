class App extends Backbone.View
  initialize: ()->
    @games = new GamesCollection()
    @gamesView = new GamesView {collection:@games}
    @render()

  render: ()->
    @initFullScreen()

  #center games div
  center_games: ()=>
    @initFullScreen() #for situation from tiny to large screen resize
    margin = ($(window).width() - $("#games").width() - 10)/2
    if margin>40 then margin = 0
    $(".content").css "margin-left", margin


  #Init full screen of games, toolbar must appear
  initFullScreen: ()=>
    if $("body").height() > $(window).height() then return
    i = 0
    while i<50
      @games.add new Game()
      i++
    setTimeout @initFullScreen, 100


$ () ->
  app = new App()
  $(window).resize app.center_games
  setTimeout app.center_games, 200






###
    $("body").delegate "a", "click", ()->
      href = $(@).attr("href");

      if href=="/"
        $("#GamePage").modal 'hide'
        history.back()
        return false
        #else if href.match(/\/games\//)
        #console.log "it is a game"
        #history.pushState null, null, href
        #$("#GamePage").modal 'show'
        return false
      else
        return true
    ###

#g = new GameView new Game
#console.log g.renderGamePage()