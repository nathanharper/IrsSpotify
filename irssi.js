var sp = getSpotifyApi(1),
    models = sp.require('sp://import/scripts/api/models'),
    player = models.player,
    cursong = '';

exports.init = init;
sp.require('jquery.min');

function init() {
    console.log('init sequence!');

    var socket = io.connect('http://localhost:8090');
    socket.on('connect', function() {
        console.log('connected successfully!');

        /* Load a cute image! */
        $.getJSON('http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=1&q=http://cuteoverload.com/feed', function (data) {
            $('#img_goes_here').html(data.responseData.feed.entries[0].content);
        });

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
