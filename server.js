var http_port = process.argv[2] || 8090,
    tcp_port = process.argv[3] || 1234,
    http = require('http'),
    io = require('socket.io'),
    net = require('net'),
    current_track = {};


server = http.createServer(function(req, res) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end(current_track.name + ' - ' + current_track.artist, "utf8");
}).listen(http_port);

// Upgrade the HTTP connection to a Websocket
websocket = io.listen(server);

// Once we've made a websocket connection...
websocket.sockets.on('connection', function(client) {

    console.log('a client connected!');

    client.on('new song', function(data) {
        current_track['artist'] = data.artist;
        current_track['name'] = data.name;
        console.log('Newtrack received!');
        console.log('Name: ' + data.name);
        console.log('Artist: ' + data.artist);
    });

});
