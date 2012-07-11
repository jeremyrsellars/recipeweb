fs = require 'fs'

String.prototype.endsWith = (str) ->
    lastIndex = this.lastIndexOf str
    return (lastIndex != -1) && (lastIndex + str.length == this.length)

exports.about = (req, res) ->
  res.render 'about', title:'About Hungry Adelaide Recipes'

exports.legal = (req, res) ->
  res.render 'legal', title:'Legal - Hungry Adelaide Recipes'

exports.index = (req, res) ->
  url = require('url').parse req.url
  filterWords = null
  query = ''
  
  recipes = 
    for x in req.app.settings.index.documents
      Name:x.document.Name, FileName:x.document.FileName 
  console.log recipes
  if url.query && url.query != ''
    console.log url.query
    querystring = require('querystring').parse url.query
    if querystring.p
      filterWords = querystring.p.split /[+ ]|%20/
      query = querystring.p
    console.log filterWords

  context =
    title:'Hungry Adelaide Recipes'
    recipes: recipes
    p : query
    path : req.app.settings.recipeRoot
  res.render 'index', context
