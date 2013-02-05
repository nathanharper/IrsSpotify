var http_port = process.argv[2] || 8090,
    tcp_port = process.argv[3] || 1234,
    http = require('http'),
    io = require('socket.io'),
    current_track = {};

server = http.createServer(function(req, res) {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end(JSON.stringify(current_track), "utf8");
}).listen(http_port);

websocket = io.listen(server);

// Once we've made a websocket connection...
websocket.sockets.on('connection', function(client) {

    console.log('a client connected!');

    client.on('new song', function(data) {
        var artist_list = [];
        for (var i = 0; i < data.artists.length; i++) {
            artist_list.push(data.artists[i].data.name);
        }
        current_track['artist'] = artist_list.join(' & ');
        current_track['name'] = data.name;
        current_track['id'] = data.uri;
    });

});
