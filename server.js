
require('coffee-script');
var app = require('./app');

var http = require('http');
var httpServer = http.createServer(app);
httpServer.listen(parseInt(process.env.port || 80));

console.log("Express server listening on port %d in %s mode for %s", httpServer.address.port, app.settings.env, app.settings.recipeRoot);

