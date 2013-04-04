var http_port = process.argv[2] || 8090,
    http = require('http'),
    // io = require('socket.io'),
    qs = require('querystring'),
    current_track = {};

server = http.createServer(function(req, res) {
    if (req.method == 'POST') {
        // TODO: make this less shittay
        var body = '';
        req.on('data', function (data) {
            body += data;
        });
        req.on('end', function() {
            console.log('POST: ' + body);
            var POST = qs.parse(body);
            set_track_data(POST);
        });
    }
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end(JSON.stringify(current_track), "utf8");
}).listen(http_port);

// websocket = io.listen(server);

// Once we've made a websocket connection...
// websocket.sockets.on('connection', function(client) {

//     console.log('a client connected!');

//     client.on('new song', set_track_data);

//     client.on('disconnect', function() {
//         current_track = {};
//     });
// });

function set_track_data(data) {
    if (!data || !data.artist || !data.name || !data.uri) return;
    current_track['artist'] = data.artists;
    current_track['name'] = data.name;
    current_track['id'] = data.uri;
}
