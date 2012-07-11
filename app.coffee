express = require 'express'
routes = require './routes'
RecipeIndexManager = require('./src/RecipeIndexManager').RecipeIndexManager

app = module.exports = express.createServer()

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + '/public' 

app.configure 'development', ->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }
  app.set 'recipeRoot', './recipes/'

app.configure 'production', ->
  app.use express.errorHandler()
  app.set 'recipeRoot', '/documents and settings/compaq_administrator/my documents/my recipes/'

app.configure ->
  new RecipeIndexManager(app.settings.recipeRoot).load (err, index)->
    console.log index.count() + ' recipes'
    app.set 'index', index

# Routes
app.get '/', (req, res) -> res.redirect '/recipes/'
app.get '/about', routes.about
app.get '/legal', routes.legal
app.get '/recipes/', routes.index
app.get '/recipes/:recipe', require('./routes/viewRecipe.js').viewRecipe


app.listen 80
console.log "Express server listening on port %d in %s mode for %s", app.address().port, app.settings.env, app.settings.recipeRoot
