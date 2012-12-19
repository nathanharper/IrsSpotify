var sp = getSpotifyApi(1);
var models = sp.require('sp://import/scripts/api/models');
var player = models.player;
var cursong = '';

exports.init = init;

function init() {
    console.log('init sequence!');

    var socket = io.connect('http://localhost:8090');
    socket.on('connect', function() {
        console.log('connected successfully!');
        player.observe(models.EVENT.CHANGE, function (e) {
            if (e.data.curtrack && player.track != null && player.track.uri != cursong) {
                cursong = player.track.uri;
                socket.emit('new song', {
                    'name' : player.track.name,
                    'artists' : player.track.artists,
                    'uri' : player.track.uri
                });
            }
        });
    });

}
