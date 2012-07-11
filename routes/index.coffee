String.prototype.endsWith = (str) ->
    lastIndex = this.lastIndexOf str
    return (lastIndex != -1) && (lastIndex + str.length == this.length)

fs = require 'fs'

exports.about = (req, res) ->
  res.render 'about', title:'About Hungry Adelaide Recipes'

exports.legal = (req, res) ->
  res.render 'legal', title:'Legal - Hungry Adelaide Recipes'

exports.index = (req, res) ->
  fs.readdir app.settings.recipeRoot, (err, aFiles) ->
    url = require('url').parse req.url
    filterWords = null
    query = ''
    
    if url.query && url.query != ''
       console.log url.query
       querystring = require('querystring').parse url.query
       if querystring.p
          filterWords = querystring.p.split /[+ ]|%20/
          query = querystring.p
       console.log(filterWords)

    recipes = []
    for f in aFiles
      continue unless f.endsWith '.recipe'

      if filterWords
        add = true
        for word in filterWords.length
           unless f.match new RegExp word, "i"
              add = false
              break

        if (!add)
          continue
      recipes.push Name:f

    context =
       title:'Hungry Adelaide Recipes'
       recipes: recipes
       p : query
       path : app.settings.recipeRoot
    res.render 'index', context
