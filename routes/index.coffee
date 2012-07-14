fs = require 'fs'
BitArray = require 'bit-array'
Idx = require 'simpleindex'
_ = require 'underscore'

class AllOfTheseQuery
  constructor: (@terms) ->

  search: (index) =>
    console.log @terms
    for term, i in @terms
      tv = index.getIndexesForTermSync term
      if i == 0
        matches = tv.copy()
      else
        matches.and tv
    matches

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
  
  index = req.app.settings.index
  indexSearcher = req.app.settings.indexSearcher

  recipes = 
    if url.query && url.query != ''
      console.log url.query
      querystring = require('querystring').parse url.query
      if querystring.p
        filterWords = querystring.p.split /[+ ]|%20/
        query = querystring.p
      try
        hits = indexSearcher.searchAllIndexesSync new AllOfTheseQuery filterWords
      catch e
        console.log 'error:'
        console.log e
      index.getItemsSync hits
    else
      x.document for x in index.documents
  recipes = _.sortBy recipes, (r) -> r.Name

  context =
    title:'Hungry Adelaide Recipes'
    recipes: recipes
    p : query
    path : req.app.settings.recipeRoot
  res.render 'index', context
