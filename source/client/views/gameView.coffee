gamePageTmplStr = '<div class="game-page-body">
  <div class="games-list popular">
    <div class="top">Popular games</div>
    <div class="panel-content"></div>
  </div>
  <div class="game-window">
    <div class="top">
      <a href="/" class="typicn previous"></a>
      <span class="game-name">{{=it.name}}</span>
      <a href="#" class="typicn thumbsUp"></a>
      <a href="#" class="typicn thumbsDown"></a>
      <a href="#" class="typicn heart"></a>
    </div>
    <div class="panel-content">{{=it.swf_link}}</div>
  </div>
  <div class="games-list similar">
    <div class="top">Similar games</div>
    <div class="panel-content"></div>
  </div>
  <div class="ad">
    <div class="top">Advertisment</div>
    <div class="panel-content"></div>
  </div>
</div>'
gamepageFn = doT.template gamePageTmplStr, undefined, {}

gameBoxTmplStr = '<a href="/games/{{=it.link}}">
    <img class="thumb" src="{{=it.thumbnail}}">
    <div class="name">{{=it.name}}</div>
  </a>'
gameboxFn = doT.template gameBoxTmplStr, undefined, {}




class GameView extends Backbone.View
  tagName: "div"
  className : "game"
  events: {
    'click a': 'renderGamePage'
  },
  render: ()->
    @$el.append gameboxFn @model
    return @$el
  renderGamePage: ()->
    console.log "RENDER"
    $("#GamePage").html gamepageFn @model
    return false




