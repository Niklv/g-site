var Game, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Game = (function(_super) {
  __extends(Game, _super);

  function Game() {
    _ref = Game.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Game.prototype.urlRoot = '/api/v1.alpha/games';

  Game.prototype.idAttribute = "_id";

  Game.prototype.initialize = function() {
    /*
    picnum = Math.floor(Math.random() * 3) + 1
    @set "_id", Math.floor(Math.random() * 1000000)
    @set "image_url", '/static/img/thumb150_' + picnum + '.jpg'
    @set "title", 'This is long default game name with number ' + @get "_id"
    @set "slug", 'default-game-link-' + @get "_id"
    @set "swf_url", 'http://www.mousebreaker.com/games/parking/INSKIN__parking-v1.1_Secure.swf'
    @set "similar", [Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000),
                     Math.floor(Math.random() * 1000000)]
    */

  };

  Game.prototype.twin = function(id) {
    this.set("_id", id);
    this.set("title", 'This is long default game name with number ' + this.get("_id"));
    this.set("slug", 'default-game-link-' + this.get("_id"));
    this.set("swf_url", 'http://www.mousebreaker.com/games/parking/INSKIN__parking-v1.1_Secure.swf');
    return this.set("similar", [Math.floor(Math.random() * 1000000), Math.floor(Math.random() * 1000000), Math.floor(Math.random() * 1000000), Math.floor(Math.random() * 1000000), Math.floor(Math.random() * 1000000)]);
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

  GamesCollection.prototype.url = '/api/v1.alpha/games';

  GamesCollection.prototype.model = Game;

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


  GamesCollection.prototype.initialize = function() {};

  GamesCollection.prototype.popular = function() {
    return [new Game, new Game, new Game, new Game, new Game, new Game];
  };

  GamesCollection.prototype.search = function(query) {
    return _.map(this.models, function(item) {
      item.toString = function() {
        return JSON.stringify(item.toJSON());
      };
      item.toLowerCase = function() {
        return item.name.toLowerCase();
      };
      item.indexOf = function(string) {
        return String.prototype.indexOf.apply(item.name, arguments);
      };
      item.replace = function(string) {
        return String.prototype.replace.apply(item.name, arguments);
      };
      return item;
    });
  };

  return GamesCollection;

})(Backbone.Collection);

var GamePageView, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

GamePageView = (function(_super) {
  __extends(GamePageView, _super);

  function GamePageView() {
    _ref = GamePageView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  GamePageView.prototype.id = "GamePage";

  GamePageView.prototype.el = $("#GamePage");

  GamePageView.prototype.templateStr = '<div class="game-page-body">\
        <div class="games-list popular">\
          <div class="top">Popular games</div>\
          <div class="panel-content">{{~it.similar :value}}{{=value}}{{~}}</div>\
        </div>\
        <div class="game-window">\
          <div class="top">\
            <a href="/" class="typicn previous"></a>\
            <span class="game-name">{{=it.name}}</span>\
            <a href="#" class="typicn thumbsUp"></a>\
            <a href="#" class="typicn thumbsDown"></a>\
            <a href="#" class="typicn heart"></a>\
          </div>\
          <div class="panel-content">\
            <div id="swf-game-wrapper">\
              <p>\
                <a href="http://www.adobe.com/go/getflashplayer">\
                  <img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />\
                </a>\
              </p>\
            </div>\
          </div>\
        </div>\
        <div class="games-list similar">\
          <div class="top">Similar games</div>\
          <div class="panel-content">{{~it.similar :value}}{{=value}}{{~}}\
          </div>\
        </div>\
        <div class="ad">\
          <div class="top">Advertisment</div>\
          <div class="panel-content"></div>\
        </div>\
      </div>';

  GamePageView.prototype.template = doT.template(GamePageView.prototype.templateStr, void 0, {});

  GamePageView.prototype.swfObject = null;

  GamePageView.prototype.events = {
    'click .heart': 'like',
    'click .thumbsUp': 'thumbsUp',
    'click .thumbsDown': 'thumbsDown'
  };

  GamePageView.prototype.render = function() {
    var context;

    context = this.model.toJSON();
    context.similar = context.similar.slice(0, 5);
    context.similar = _.map(context.similar, function(similar_id) {
      var g, gv;

      g = new Game({
        _id: similar_id
      });
      gv = new GameView({
        model: g
      });
      return gv.render()[0].outerHTML;
    });
    this.$el.html(this.template(context));
    return this.$el;
  };

  GamePageView.prototype.setupSwfObject = function() {
    return swfobject.embedSWF(this.model.get("swf_link"), "swf-game-wrapper", "100%", "100%", "9.0.0");
  };

  GamePageView.prototype.deleteSwfObject = function() {
    return swfobject.removeSWF("swf-game-wrapper");
  };

  GamePageView.prototype.like = function() {
    return console.log('like');
  };

  GamePageView.prototype.thumbsUp = function() {
    return console.log('thumbsUp');
  };

  GamePageView.prototype.thumbsDown = function() {
    return console.log('thumbsDown');
  };

  return GamePageView;

})(Backbone.View);

var GameView, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

GameView = (function(_super) {
  __extends(GameView, _super);

  function GameView() {
    this.render = __bind(this.render, this);    _ref = GameView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  GameView.prototype.tagName = "div";

  GameView.prototype.className = "game";

  GameView.prototype.templateStr = '<a href="/games/{{=it.slug}}">\
      <img class="thumb" src="{{=it.image_url}}">\
      <div class="name">{{=it.title}}</div>\
    </a>';

  GameView.prototype.template = doT.template(GameView.prototype.templateStr, void 0, {});

  GameView.prototype.render = function() {
    this.$el.append(this.template(this.model.toJSON()));
    return this.$el;
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

  GamesView.prototype.el = "div#games";

  GamesView.prototype.initialize = function() {
    var _this = this;

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
    return this.$el;
  };

  GamesView.prototype.appendGame = function(game, games, options) {
    var gameview;

    gameview = new GameView({
      model: game
    });
    this.$el.append(gameview.render());
    return this.$el;
  };

  GamesView.prototype.remove = function() {
    this.infiniScroll.destroy();
    return Backbone.View.prototype.remove.call(this);
  };

  return GamesView;

})(Backbone.View);

var App, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

App = (function(_super) {
  __extends(App, _super);

  function App() {
    this.initFullScreen = __bind(this.initFullScreen, this);
    this.center_games = __bind(this.center_games, this);    _ref = App.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  App.prototype.initialize = function() {
    this.games = new GamesCollection();
    _.each($('.game'), function(game_el) {
      var game, gameView, slug;

      game = new Game;
      slug = $(game_el).find('a').attr('href');
      game.set({
        title: $(game_el).find('div.name').html(),
        image_url: $(game_el).find('img.thumb').attr('src'),
        slug: slug.substr(slug.lastIndexOf('/') + 1)
      });
      gameView = new GameView({
        model: game,
        el: game_el
      });
      return this.add(game);
    }, this.games);
    this.gamesView = new GamesView({
      collection: this.games
    });
    this.gamePageView = new GamePageView();
    return this.initFullScreen();
  };

  App.prototype.center_games = function() {};

  App.prototype.initFullScreen = function() {
    /*
    i = 0
    while i<50
      @games.add new Game()
      i++
    
    setTimeout @initFullScreen, 100
    */

  };

  App.prototype.routes = {
    "games/:game_link": "gamepage",
    "": "index"
  };

  App.prototype.init = function() {};

  App.prototype.index = function() {
    $('#GamePage').hide();
    $('#GamePageBackdrop').hide();
    return this.gamePageView.deleteSwfObject();
  };

  App.prototype.gamepage = function(game_link) {
    var id;

    id = game_link.split("-");
    id = id[id.length - 1];
    this.gamePageView.model = new Game();
    this.gamePageView.model.twin(id);
    this.gamePageView.model.set("link", game_link);
    $('#GamePage').replaceWith(this.gamePageView.render());
    this.gamePageView.setupSwfObject();
    $('#GamePageBackdrop').show();
    return $('#GamePage').show();
  };

  return App;

})(Backbone.Router);

$(function() {
  var app,
    _this = this;

  app = new App();
  Backbone.history.start({
    pushState: true
  });
  $(document).delegate("a", "click", function(e) {
    var href, uri;

    if (e.currentTarget.getAttribute("nobackbone")) {
      return;
    }
    href = e.currentTarget.getAttribute('href');
    if (!href) {
      return true;
    }
    if (href[0] === '/') {
      uri = Backbone.history._hasPushState ? e.currentTarget.getAttribute('href').slice(1) : "!/" + e.currentTarget.getAttribute('href').slice(1);
      app.navigate(uri, {
        trigger: true
      });
      return false;
    }
  });
  return $('.search-bar .search-query').typeahead({
    source: function(query, process) {
      return app.games.search(query);
    },
    matcher: function() {
      return true;
    },
    sorter: function(items) {
      return items;
    },
    highlighter: function(game) {
      var gv;

      gv = new GameView({
        model: game
      });
      return gv.render();
    },
    updater: function(itemString) {
      var item;

      item = JSON.parse(itemString);
      app.navigate('/games/' + item.link, {
        trigger: true
      });
    },
    items: 8
  });
});
