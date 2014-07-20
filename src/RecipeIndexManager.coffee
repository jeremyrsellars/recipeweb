fs = require 'fs'
path = require 'path'
Idx = require 'simpleindex'
RecipeParser = require('./RecipeParser').RecipeParser

###
    for f in files
      continue unless f.endsWith '.recipe'
      recipes.push ({Name:f});

###

converter =
  filename: (r) ->
    path.basename r.filename
  name:  (r) ->
    names = [p.Name for p in r.Parts if r.Parts]
    names.push r.Name
    names.join '; '
  source: (r) -> (r.Source ? {}).Name ? []
  tag: (r) -> 
    tags = 
      tag.Name.replace(/\W/g, '_') for tag in r.Tags ? []
    new Idx.LowerCaseFilter().filter tags
  method: (r) -> [part.PreparationMethod for part in r.Parts ? []].join '\r\n'
  instructions: (r) -> [line for line in part.InstructionLines ? [] for part in r.Parts ? []].join '\r\n'
  ingredient: (r) -> [ingredient.Ingredient for ingredient in part.Ingredients ? [] for part in r.Parts ? []].join '\r\n'

class SimilarFileNameQuery
  constructor: (docInv, filename) ->
    @terms = ("filename:#{term}" for term in docInv.invertSync filename)
  search: (index) =>
    for term, i in @terms
      tv = index.getIndexesForTermSync term
      if i == 0
        matches = tv.copy()
      else
        matches.and tv
    matches

class module.exports.RecipeIndexManager
  constructor: (@recipeFolder) ->
    @index = new Idx.Index()
    @backlog = 0
    @loaded = 0
    @db = new Idx.DocumentBuilder converter
    @docInv = new Idx.DocumentInverter()
    @docInv.filter = new Idx.StopWordFilter Idx.StopWordFilter.MySqlStopWords, @docInv.filter

  load: (@cb)=>
    console.log 'loading recipes from ' + @recipeFolder
    fs.readdir @recipeFolder, (err, files) =>
      return @loadFiles files, cb unless err?
      cb err
    @watchFiles()

  loadFiles: (@files, cb) =>
    safeLoadFile = (f) =>
      return unless f.endsWith '.recipe'
      @backlog++
      @loadFile f, false
    @partitionedForEach @files, 10, safeLoadFile, () => @watchFiles()
        
  partitionedForEach: (lst, partitionSize, fn, cb) =>
     if lst == [] or lst == null
       return cb()
     firstN = lst[0..partitionSize - 1]
     rest = lst[partitionSize..]
     for item in firstN
        fn item
     setImmediate () => @partitionedForEach rest, partitionSize, fn, cb

  watchFiles: () =>
    fs.watch @recipeFolder, (event, file) =>
      return unless file.endsWith '.recipe'
      console.log "#{event} #{file}"
      if event is 'change'
        @loadFile file, true
    console.log "watching #{@recipeFolder}"

  loadFile: (file, reload) =>
    new RecipeParser(@recipeFolder + file).parse (err, recipe) =>
      console.error err if err
      recipe.FileName = file
      @addRecipe recipe, reload
      @fileLoaded file

  addRecipe: (recipe, reload) =>
    builtRecipe = @db.build recipe
    doc = @docInv.invertSync builtRecipe
    if reload
      filename = builtRecipe.filename
      fnQuery = new SimilarFileNameQuery @docInv, filename
      matches = fnQuery.search @index
      replaced = false
      if matches isnt null
        matches.forEach (isMatch, index) =>
          return unless isMatch
          d = @index.documents[index]
          return unless d.document.FileName is filename
          replaced = true
          console.log "replaced at #{index}"
          @index.replaceAtSync index, recipe, doc
      return if replaced
      console.log "could not find replacement for ", filename
    @index.addSync recipe, doc

  fileLoaded: (file) =>
    @loaded++
    if @loaded < @backlog
      return
    @cb null, @index
