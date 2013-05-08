var http_port = process.argv[2] || 8090,
    http = require('http'),
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

function set_track_data(data) {
    if (!data || !data.artists || !data.name || !data.uri) {
        console.log('something broke');
        return;
    }
    current_track['artist'] = data.artists;
    current_track['name'] = data.name;
    current_track['id'] = data.uri;
}
