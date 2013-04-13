var Game, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Game = (function(_super) {
  __extends(Game, _super);

  function Game() {
    _ref = Game.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Game.prototype.initialize = function() {
    var picnum;

    picnum = Math.floor(Math.random() * 3) + 1;
    this.thumbnail = '/static/img/thumb150_' + picnum + '.jpg';
    this.name = 'Default game name';
    this.link = 'default-game-name';
    this.swf_link = 'game/swf/link.swf';
  };

  return Game;

})(Backbone.Model);

var GamesCollection, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

GamesCollection = (function(_super) {
  __extends(GamesCollection, _super);

  function GamesCollection() {
    _ref = GamesCollection.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  GamesCollection.prototype.model = Game;

  GamesCollection.prototype.url = '/games';

  /*
  fetch : ()->
    console.log "fetch!"
    i =0
    while i<50
      this.add new Game()
      i++
    parm = Backbone.Collection.prototype.fetch.call this
    return parm
  */


  return GamesCollection;

})(Backbone.Collection);

var AppView, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

AppView = (function(_super) {
  __extends(AppView, _super);

  function AppView() {
    _ref = AppView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  AppView.prototype.initialize = function() {
    this.el = $("div#appView");
  };

  AppView.prototype.render = function() {};

  AppView.prototype.addOne = function() {
    return console.log("ADDONE");
  };

  return AppView;

})(Backbone.View);

var GameView, gameBoxTmplStr, gamePageTmplStr, gameboxFn, gamepageFn, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

gamePageTmplStr = '<div class="game-page-body">\
  <div class="games-list popular">\
    <div class="top">Popular games</div>\
    <div class="panel-content"></div>\
  </div>\
  <div class="game-window">\
    <div class="top">\
      <a href="/" class="typicn previous"></a>\
      <span class="game-name">{{=it.name}}</span>\
      <a href="#" class="typicn thumbsUp"></a>\
      <a href="#" class="typicn thumbsDown"></a>\
      <a href="#" class="typicn heart"></a>\
    </div>\
    <div class="panel-content">{{=it.swf_link}}</div>\
  </div>\
  <div class="games-list similar">\
    <div class="top">Similar games</div>\
    <div class="panel-content"></div>\
  </div>\
  <div class="ad">\
    <div class="top">Advertisment</div>\
    <div class="panel-content"></div>\
  </div>\
</div>';

gamepageFn = doT.template(gamePageTmplStr, void 0, {});

gameBoxTmplStr = '<div class="game">\
  <a href="/games/{{=it.link}}">\
    <img class="thumb" src="{{=it.thumbnail}}">\
    <div class="name">{{=it.name}}</div>\
  </a>\
</div>';

gameboxFn = doT.template(gameBoxTmplStr, void 0, {});

GameView = (function(_super) {
  __extends(GameView, _super);

  function GameView() {
    _ref = GameView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  GameView.prototype.tagName = "div";

  GameView.prototype.className = "game";

  GameView.prototype.events = {
    'click a': 'renderGamePage'
  };

  GameView.prototype.render = function() {
    return gameboxFn(this.model);
  };

  GameView.prototype.renderGamePage = function() {
    console.log("RENDER");
    $("#GamePage").html(gamepageFn(this.model));
    return false;
  };

  return GameView;

})(Backbone.View);

var GamesView, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

GamesView = (function(_super) {
  __extends(GamesView, _super);

  function GamesView() {
    _ref = GamesView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  GamesView.prototype.initialize = function() {
    var _this = this;

    _.bindAll(this, "render");
    this.el = $("#games");
    this.listenTo(this.collection, 'add', this.appendGame);
    return this.infiniScroll = new Backbone.InfiniScroll(this.collection, {
      strict: false,
      scrollOffset: 600,
      error: function() {
        var i, _results;

        i = 0;
        _results = [];
        while (i < 20) {
          _this.collection.add(new Game());
          _results.push(i++);
        }
        return _results;
      }
    });
  };

  GamesView.prototype.render = function() {
    this.collection.forEach(function(game) {
      return this.appendGame(game);
    });
    return this.el;
  };

  GamesView.prototype.appendGame = function(game, games, options) {
    var gameview;

    gameview = new GameView({
      model: game
    });
    $(this.el).append(gameview.render());
    gameview.delegateEvents();
    return this.el;
  };

  GamesView.prototype.remove = function() {
    this.infiniScroll.destroy();
    return Backbone.View.prototype.remove.call(this);
  };

  return GamesView;

})(Backbone.View);

$(function() {
  var center_games, games, gamesView, initFullScreen,
    _this = this;

  games = new GamesCollection();
  gamesView = new GamesView({
    collection: games
  });
  center_games = function() {
    var margin;

    initFullScreen();
    margin = ($(window).width() - $("#games").width() - 10) / 2;
    if (margin > 40) {
      margin = 0;
    }
    return $(".content").css("margin-left", margin);
  };
  initFullScreen = function() {
    var i;

    if ($("body").height() > $(window).height()) {
      return;
    }
    i = 0;
    while (i < 50) {
      games.add(new Game());
      i++;
    }
    return setTimeout(initFullScreen, 100);
  };
  center_games();
  $(document).ready(function() {
    $(window).resize(center_games);
    return setTimeout(center_games, 200);
  });
  /*
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
  */

});
