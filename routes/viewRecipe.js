var RecipeParser = require('../src/RecipeParser').RecipeParser;
exports.viewRecipe = function(req, res){
  console.log('===========' + req.params.recipe + '==========');
  new RecipeParser(req.app.settings.recipeRoot + req.params.recipe).parse (function(err, recipe){
      if (err)
        console.log(err);
      console.log(recipe);
      writeRecipe(res, recipe);
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
