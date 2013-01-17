var http_port = process.argv[2] || 8090,
    tcp_port = process.argv[3] || 1234,
    http = require('http'),
    io = require('socket.io'),
    current_track = {};

server = http.createServer(function(req, res) {
    var data = '',
        artist_list = [];
    if (current_track.artists && current_track.name) {
        for (var i = 0; i < current_track.artists.length; i++) {
            artist_list.push(current_track.artists[i].data.name);
        }
        data = artist_list.join(' & ') + ' - ' + current_track.name;
    }

    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end(data, "utf8");
}).listen(http_port);

websocket = io.listen(server);

// Once we've made a websocket connection...
websocket.sockets.on('connection', function(client) {

    console.log('a client connected!');

    client.on('new song', function(data) {
        current_track['artists'] = data.artists;
        current_track['name'] = data.name;
    });

});
