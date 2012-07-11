
/**
 * Module dependencies.
 */
require('coffee-script');
var express = require('express')
  , routes = require('./routes')
  , RecipeIndexManager = require('./src/RecipeIndexManager').RecipeIndexManager;


//var 
app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
  app.set('recipeRoot', './recipes/');
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
  app.set('recipeRoot', '/documents and settings/compaq_administrator/my documents/my recipes/');
});

app.configure(function(){
  new RecipeIndexManager(app.settings.recipeRoot).load(function(err, index){
    console.log(index.count() + ' recipes');
    app.set('index', index);
  });
});
// Routes

app.get('/', function(req, res) {res.redirect('/recipes/');});
app.get('/about', routes.about);
app.get('/legal', routes.legal);
app.get('/recipes/', routes.index);
app.get('/recipes/:recipe', require('./routes/viewRecipe.js').viewRecipe);


app.listen(80);
console.log("Express server listening on port %d in %s mode for %s", app.address().port, app.settings.env, app.settings.recipeRoot);
