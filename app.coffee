express = require 'express'
routes = require './routes'
RecipeIndexManager = require('./src/RecipeIndexManager').RecipeIndexManager

Idx = require 'simpleindex'

app = module.exports = express()

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + '/public' 

app.configure 'development', ->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }
  app.set 'recipeRoot', process.env['recipes'] ? './recipes/'

app.configure 'production', ->
  app.use express.errorHandler()
  app.set 'recipeRoot', process.env['recipes'] ? '/documents and settings/compaq_administrator/my documents/my recipes/'

app.configure ->
  new RecipeIndexManager(app.settings.recipeRoot).load (err, index)->
    console.log err if err
    console.log index.count() + ' recipes'
    app.set 'index', index
    app.set 'indexSearcher', new Idx.IndexSearcher index

# Routes
app.get '/', (req, res) -> res.redirect '/recipes/'
app.get '/about', routes.about
app.get '/legal', routes.legal
app.get '/recipes/', routes.index
app.get '/recipes/:recipe', require('./routes/viewRecipe.js').viewRecipe
