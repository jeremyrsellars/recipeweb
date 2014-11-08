express = require 'express'
routes = require './routes'
path = require 'path'
RecipeIndexManager = require('./src/RecipeIndexManager').RecipeIndexManager

Idx = require 'simpleindex'

app = module.exports = express()

normalizeDirectory = (d) ->
  if d and d.length > 0 && d[d.length - 1] != path.sep
    d + path.sep
  else
    d

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use '/recipes/', express.static __dirname + '/public' 

app.configure 'development', ->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }
  recipeFolder = process.env['recipes'] ? './recipes/'
  app.set 'recipeRoot', normalizeDirectory recipeFolder

app.configure 'production', ->
  app.use express.errorHandler()
  recipeFolder = process.env['recipes'] ? './recipes/'
  app.set 'recipeRoot', normalizeDirectory recipeFolder

app.configure ->
  new RecipeIndexManager(app.settings.recipeRoot).load (err, index)->
    console.log err if err
    console.log index.count() + ' recipes'
    app.set 'index', index
    app.set 'indexSearcher', new Idx.IndexSearcher index

# Routes
app.get '/', (req, res) -> res.redirect '/recipes/'
app.get '/recipes/about', routes.about
app.get '/recipes/legal', routes.legal
app.get '/recipes/', routes.index
app.get '/recipes/:recipe', require('./routes/viewRecipe.js').recipe
