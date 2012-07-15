xml = require 'node-xml'

class module.exports.RecipeParser
  constructor: (@filename) ->

  parse: (fn) =>
    recipe = {}
    lastElem = ''
    parser = new xml.SaxParser (cb) =>
      cb.onStartDocument () =>
        return
      cb.onEndDocument () =>
        parser.pause()
        fn null, recipe
      cb.onStartElementNS (elem, attrs, prefix, uri, namespaces) =>
        if elem != 'String'
            lastElem = elem
        if elem == "Recipe"
            @processRecipe recipe, attrs
        else if elem == "RecipePart"
            @processRecipePart recipe, attrs
        else if elem == "PreparationMethod"
            @processMethod recipe, attrs
        else if elem == "Rating"
            @processRating recipe, attrs
        else if elem == "Source"
            @processSource recipe, attrs
        else if elem == "Tags"
            @processTags recipe, attrs
        else if elem == "Tag"
            @processTag recipe, attrs
        else if elem == "IngredientDetail"
            @processIngredientDetail recipe, attrs

      cb.onCdata (cdata) =>
        if lastElem == 'Instructions'
          part = recipe.Parts[recipe.Parts.length - 1]
          part.Instructions = cdata
          part.InstructionLines = cdata.split /\r\n|\r|\n/

    #warning: security vulnerability:  parses any file in system!!!!!!
    parser.parseFile @filename

  processRecipe: (recipe, attrs)=>
    @setAttributes recipe, attrs

  processRecipePart: (recipe, attrs)=>
    recipePart = {}
    @setAttributes recipePart, attrs
    recipe.Parts = [] unless recipe.Parts
    recipe.Parts.push recipePart

  processIngredientDetail: (recipe, attrs)=>
    ingredient = {}
    @setAttributes ingredient, attrs
    # Add to last part.
    part = recipe.Parts[recipe.Parts.length - 1]
    part.Ingredients = [] unless part.Ingredients
    part.Ingredients.push ingredient

  processRating: (recipe, attrs)=>
    rating = {}
    @setAttributes rating, attrs
    recipe.Ratings = [] unless recipe.Ratings
    recipe.Ratings.push rating

  processSource: (recipe, attrs)=>
    source = {}
    @setAttributes source, attrs
    recipe.Source = source

  processMethod: (recipe, attrs)=>
    @tagIsMethod = true

  processTags: (recipe, attrs)=>
    @tagIsMethod = false

  processTag: (recipe, attrs)=>
    tag = {}
    @setAttributes tag, attrs
    if @tagIsMethod
      part = recipe.Parts[recipe.Parts.length - 1]
      console.log 'part PreparationMethod: ' + tag
      part.PreparationMethod = tag
    else
      console.log 'tag: ' + tag
      recipe.Tags = [] unless recipe.Tags
      recipe.Tags.push tag

  setAttributes: (obj, attrs)=>
    for attr in attrs
      obj[attr[0]] = attr[1] unless attr[0] == '_NS'
