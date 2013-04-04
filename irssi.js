var sp = getSpotifyApi(1),
    models = sp.require('sp://import/scripts/api/models'),
    player = models.player,
    cursong = '',
    final_countdown = 0;

exports.init = init;
sp.require('jquery.min');

function init() {
    load_cute_image();

    // Observe Spotify song change event
    player.observe(models.EVENT.CHANGE, function (e) {
        if (e.data.curtrack && player.track != null && player.track.uri != cursong) {
            cursong = player.track.uri;

            artist_list = [];
            for (var i = 0; i < player.track.artists.length; i++) {
                artist_list.push(player.track.artists[i].data.name);
            }
            var request = {
                'name' : player.track.name,
                'artists' : artist_list.join(' & '),
                'uri' : player.track.uri
            };

            $.post('http://localhost:' + $('#port_num').val(), request, function(resp) {
                console.log(resp);
            },'json');

            if (final_countdown == 10) {
                final_countdown = 0;
                load_cute_image();
            }
            final_countdown++;
        }
    });
}

function load_cute_image() {
    $.getJSON('http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=1&q=http://cuteoverload.com/feed', function (data) {
        $('#img_goes_here').html(data.responseData.feed.entries[0].content);
    });
}
