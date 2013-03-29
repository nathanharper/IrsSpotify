var sp = getSpotifyApi(1),
    models = sp.require('sp://import/scripts/api/models'),
    player = models.player,
    cursong = '',
    final_countdown = 0,
    socket;

exports.init = init;
sp.require('jquery.min');

function init() {
    load_cute_image();

    $('#connect_submit').click(function() {
        var port = $('#port_num').val();
        server_connect(port);
    });
    $('#autoconnect').click(function() {
        var port = $('#port_num').val();
        server_connect(port, true);
    });

    // Observe Spotify song change event
    player.observe(models.EVENT.CHANGE, function (e) {
        if (e.data.curtrack && player.track != null && player.track.uri != cursong) {
            cursong = player.track.uri;

            if (socket) {
                socket.emit('new song', {
                    'name' : player.track.name,
                    'artists' : player.track.artists,
                    'uri' : player.track.uri
                });
            }

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

function server_connect(port, autoconnect) {
    socket = io.connect('http://localhost:' + port); // 'socket' is global scope so the observer can write to it
    socket.on('connect', function() {
        console.log('CONNECTED on ' + port)

        $('#connect_submit').attr('disabled', 'disabled');
        $('#autoconnect').attr('disabled', 'disabled');
        $('#connection_status')
            .css('color','green')
            .html('<b>CONNECTED on port ' + port + '</b>');
    }).on('disconnect', function() {
        $('#connection_status')
            .css('color','red')
            .html('<i>Disconnected</i>');
        if (!autoconnect) {
            socket = null;
            $('#connect_submit').removeAttr('disabled');
            $('#autoconnect').removeAttr('disabled');
        }
        else {
            console.log('Lost connection, trying to reconnect...')
            socket.socket.connect();
        }
    });
}
