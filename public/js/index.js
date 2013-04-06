Game = Backbone.Model.extend({
    defaults: {
        name: 'Default game name',
        thumbnail: '/img/thumb150_1.jpg'
    }
});

GameView = Backbone.View.extend({


});


var game = new Game();
console.log(game.toJSON());