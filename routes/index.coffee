fs = require 'fs'
BitArray = require 'bit-array'
Idx = require 'simpleindex'
_ = require 'underscore'

class AllOfTheseQuery
  constructor: (@terms) ->
  search: (index) =>
    for term, i in @terms
      tv = index.getIndexesForTermSync term
      if i == 0
        matches = tv.copy()
      else
        matches.and tv
    matches

class AllOfTheseSubstringQuery
  constructor: (@terms) ->
  search: (index) =>
    indexTerms = null
    andVectors = []
    for term, i in @terms
      if 0 < term.indexOf ':'
        andVectors.push index.getIndexesForTermSync term
      else
        indexTerms ?= index.getTermsSync()
        filter = (it) -> (it.term.indexOf term) >= 0
        orTerms =
          for t in _.filter indexTerms, filter
            t.term
        if orTerms.length == 0
          andVectors.push index.getIndexesForTermSync term
        else
          orVectors = 
            for orTerm in orTerms
              index.getIndexesForTermSync orTerm
          orValueVector = null
          for tv, i in orVectors
            if i == 0
              orValueVector = tv.copy()
            else
              orValueVector.or tv
          andVectors.push orValueVector

    for tv, i in andVectors
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

  recipes = null
  if url.query && url.query != ''
    console.log 'query: ' + url.query
    querystring = require('querystring').parse url.query
    if querystring.p? && querystring.p
      filterWords = querystring.p.split /[+ ]|%20/
      query = querystring.p
      try
        hits = indexSearcher.searchAllIndexesSync new AllOfTheseSubstringQuery filterWords
      catch e
      recipes = index.getItemsSync hits
  if !recipes
    recipes =
      for x in index.documents
        x.document
  recipes = _.sortBy recipes, (r) -> r.Name

  context =
    title:'Hungry Adelaide Recipes'
    recipes: recipes
    p : query
    path : req.app.settings.recipeRoot
  res.render 'index', context
