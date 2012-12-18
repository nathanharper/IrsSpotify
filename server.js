var http_port = process.argv[2] || 8090,
    tcp_port = process.argv[3] || 8091,
    http = require('http'),
    io = require('socket.io'),
    net = require('net'),
    // socket = net.createConnection(http_port);

// socket.on('connect', function() {

    server = http.createServer(function(req, res) {
    }).listen(http_port);

    // Upgrade the HTTP connection to a Websocket
    websocket = io.listen(server);

    // Once we've made a websocket connection...
    websocket.sockets.on('connection', function(client) {

        console.log('a client connected!');

        client.on('new song', function(data) {
            console.log('Newtrack received!');
            console.log('Name: ' + data.name);
            console.log('Artist: ' + data.artist);
        });

    });
// });
