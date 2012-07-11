fs = require('fs')
Idx = require 'simpleindex'
RecipeParser = require('./RecipeParser').RecipeParser

###
    for f in files
      continue unless f.endsWith '.recipe'
      recipes.push ({Name:f});

###

converter =
  name:  (r) ->
    names = [p.Name for p in r.Parts if r.Parts]
    names.push r.Name
    names.join '; '
  method: (r) -> [part.PreparationMethod for part in r.Parts ? []].join '\r\n'
  instructions: (r) -> [line for line in part.InstructionLines ? [] for part in r.Parts ? []].join '\r\n'
  ingredients: (r) -> [ingredient.Ingredient for ingredient in part.Ingredients ? [] for part in r.Parts ? []].join '\r\n'


class module.exports.RecipeIndexManager
  constructor: (@recipeFolder) ->
    @index = new Idx.Index()
    @backlog = 0
    @loaded = 0
    @db = new Idx.DocumentBuilder converter
    @docInv = new Idx.DocumentInverter()

  load: (@cb)=>
    console.log 'loading files from ' + @recipeFolder
    fs.readdir @recipeFolder, (err, files) =>
      return @loadFiles files, cb unless err?
      cb err

  loadFiles: (@files, cb) =>
    recipes = []
    for f in files
      continue unless f.endsWith '.recipe'
      @backlog++
      @loadFile f

  loadFile: (file, cb) =>
    new RecipeParser(@recipeFolder + file).parse (err, recipe) =>
      recipe.FileName = file
      @addRecipe recipe
      @fileLoaded file

  addRecipe: (recipe) =>
    @index.addSync recipe, @docInv.invertSync @db.build recipe

  fileLoaded: (file) =>
    @loaded++
    if @loaded < @backlog
      return
    @cb null, @index
