class App extends Backbone.Router
  initialize: ()->
    #init games collection from html
    @games = new GamesCollection()
    _.each $('.game'), (game_el)->
      game = new Game
      slug = $(game_el).find('a').attr 'href'
      game.set
        title: $(game_el).find('div.name').html()
        image_url: $(game_el).find('img.thumb').attr 'src'
        slug: slug.substr(slug.lastIndexOf('/') + 1)
      gameView = new GameView
        model:game
        el:game_el
      @add game
    , @games





    @gamesView = new GamesView {collection:@games}
    @gamePageView = new GamePageView()
    @initFullScreen()

  #center games div
  center_games: ()=>
    #@initFullScreen() #for situation from tiny to large screen resize
    #margin = ($(window).width() - $("#games").width() - 10)/2
    #if margin>40 then margin = 0
    #$(".content").css "margin-left", margin

  #Init full screen of games, toolbar must appear
  initFullScreen: ()=>
    #if $("body").height() > $(window).height() then return
    ###
    i = 0
    while i<50
      @games.add new Game()
      i++

    setTimeout @initFullScreen, 100
    ###

  routes:{
    "games/:game_link": "gamepage"
    "": "index"
  }

  init: ()->
    return

  index: ()->
    $('#GamePage').hide()
    $('#GamePageBackdrop').hide()
    @gamePageView.deleteSwfObject()

  gamepage: (game_link)->
    #fetch from server by game_link, but for this moment we just create new one
    id = game_link.split "-"
    id = id[id.length-1]
    @gamePageView.model = new Game()
    @gamePageView.model.twin id
    @gamePageView.model.set "link", game_link
    $('#GamePage').replaceWith @gamePageView.render()
    @gamePageView.setupSwfObject()
    $('#GamePageBackdrop').show()
    $('#GamePage').show()



$ () ->
  app = new App()
  #$(window).resize app.center_games
  #setTimeout app.center_games, 200

  Backbone.history.start {pushState: true}
  $(document).delegate "a", "click", (e)->
    if e.currentTarget.getAttribute("nobackbone") then return
    href = e.currentTarget.getAttribute('href')
    return true unless href

    if href[0] is '/'
      uri = if Backbone.history._hasPushState then e.currentTarget.getAttribute('href').slice(1) else "!/"+e.currentTarget.getAttribute('href').slice(1)
      app.navigate uri, {trigger:true}
      return false

  $('.search-bar .search-query').typeahead
    source: (query, process)-> return app.games.search(query)
    matcher: ()-> true
    sorter: (items)->
      items
    highlighter: (game)->
      gv = new GameView {model:game}
      return gv.render()
    updater: (itemString) =>
      item = JSON.parse(itemString)
      app.navigate '/games/'+item.link, {trigger:true}
      return
    items: 8
