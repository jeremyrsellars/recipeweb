
require('coffee-script');
var app = require('./app');

var port = parseInt(process.env.port || 80);
var http = require('http');
var httpServer = http.createServer(app);
httpServer.listen(port);

for (var v in process.env) if (v[0] != 'n') console.log(v + '=' + process.env[v]);

console.log("Express server listening on port %d in %s mode for %s", port, app.settings.env, app.settings.recipeRoot);

