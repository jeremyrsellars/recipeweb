var RecipeParser = require('../src/RecipeParser').RecipeParser;

parseRecipe = function(req, continuation){
  console.log('===========' + req.params.recipe + '==========');
  new RecipeParser(req.app.settings.recipeRoot + req.params.recipe.replace(/.json$|.recipe$|$/,'.recipe')).parse(continuation);
};

exports.recipe = function(req, res){
  if((/.*\.json$/).test(req.url))
    return exports.json(req, res);
  if((/.*\.recipe$/).test(req.url))
    return exports.html(req, res);
};

exports.html = function(req, res){
  console.log('===========' + req.params.recipe + '==========');
  parseRecipe(req, function(err, recipe){
      if (err)
        console.log(err);
      writeRecipe(res, recipe);
  });
};

exports.json = function(req, res){
  console.log('===========' + req.params.recipe + '==========');
  parseRecipe(req, function(err, recipe){
      if (err)
        console.log(err);
      res.setHeader('Content-Type', 'application/json');
      res.send(JSON.stringify(recipe, null, 2));
  });
};

var writeRecipe = function(res, recipe){
   if (!recipe.Name)
     return;
   

   var rValue = 0;
   var rCount = 0;

   if (recipe.Ratings)
   {
      var rValue = 0;
      var rCount = 0;
      for (var rating in recipe.Ratings)
      {
         if (rating.Value)
         {
            rValue += rating.Value;
            rCount++;
         }
      }
   }
   recipe.RatingCount = rCount;
   recipe.RatingValue = rCount == 0 ? 0 : (int)(rValue / rCount);

   res.render('viewRecipe', {title:recipe.Name, body:recipe, recipe:recipe, layout:true});
};
