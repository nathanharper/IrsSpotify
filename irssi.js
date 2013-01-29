var sp = getSpotifyApi(1),
    models = sp.require('sp://import/scripts/api/models'),
    player = models.player,
    cursong = '',
    final_countdown = 0;

exports.init = init;
sp.require('jquery.min');

function init() {
    console.log('init sequence!');

    load_cute_image();

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

                if (final_countdown == 20) {
                    final_countdown = 0;
                    load_cute_image();
                }
                final_countdown++;
                console.log('songs played since last RSS load: ' + final_countdown);
            }
        });
    });

}

function load_cute_image() {
    $.getJSON('http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=1&q=http://cuteoverload.com/feed', function (data) {
        $('#img_goes_here').html(data.responseData.feed.entries[0].content);
    });
}
