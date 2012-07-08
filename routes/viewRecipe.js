
var xml = require("node-xml");

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

var processRecipe = function(recipe, attrs){
   setAttributes(recipe, attrs);
//   console.log(recipe);
};

var processRecipePart = function(recipe, attrs){
   var recipePart = new Object();
   setAttributes(recipePart, attrs);
   if (!recipe.Parts)
      recipe.Parts = new Array();
   recipe.Parts.push (recipePart);
};

var processIngredientDetail = function(recipe, attrs){
   var ingredient = new Object();
   setAttributes(ingredient, attrs);
   // Add to last part.
   var part = recipe.Parts[recipe.Parts.length - 1];
   if (!part.Ingredients)
      part.Ingredients = new Array();
   part.Ingredients.push (ingredient);
};

var processRating = function(recipe, attrs){
//   console.log('Rating!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
   var rating = new Object();
   setAttributes(rating, attrs);
   if (!recipe.Ratings)
      recipe.Ratings = new Array();
   recipe.Ratings.push (rating);
};

var setAttributes = function(obj, attrs){
   for (var i in attrs)
   {
      if (attrs[i][0] != '_NS') obj[attrs[i][0]] = attrs[i][1];
   }
};

exports.viewRecipe = function(req, res){
console.log('===========' + req.params.recipe + '==========');
 var recipe = new Object ();
 var lastElem = '';
 var parser = new xml.SaxParser(function(cb) {
  cb.onStartDocument(function() {
  });
  cb.onEndDocument(function() {
     parser.pause();
     writeRecipe(res, recipe);     
     return;
  });
  cb.onStartElementNS(function(elem, attrs, prefix, uri, namespaces) {
      if (elem != 'String')
         lastElem = elem;
      if (elem == "Recipe")
         processRecipe(recipe, attrs);
      else if (elem == "RecipePart")
         processRecipePart(recipe, attrs);
      else if (elem == "Rating")
         processRating(recipe, attrs);
      else if (elem == "IngredientDetail")
         processIngredientDetail(recipe, attrs);
//      console.log("=> Started: " + elem + " uri="+uri +" (Attributes: " + JSON.stringify(attrs) + " )");
  });
  cb.onEndElementNS(function(elem, prefix, uri) {
//      console.log("<= End: " + elem + " uri=" + uri + "\n");
          //parser.pause();// pause the parser
         //setTimeout(function (){parser.resume();}, 200); //resume the parser
  });
  cb.onCharacters(function(chars) {
      //sys.puts('<CHARS>'+chars+"</CHARS>");
  });
  cb.onCdata(function(cdata) {
      if (lastElem == 'Instructions')
      {
        var part = recipe.Parts[recipe.Parts.length - 1];
        part.Instructions = cdata;
        part.InstructionLines = cdata.split(/\r\n|\r|\n/);
      }
      //else
//        console.log(lastElem + ":  <CDATA>"+cdata+"</CDATA>");
  });
  cb.onComment(function(msg) {
//      console.log("<COMMENT>"+msg+"</COMMENT>");
  });
  cb.onWarning(function(msg) {
//      console.log("<WARNING>"+msg+"</WARNING>");
  });
  cb.onError(function(msg) {
//      console.log("<ERROR>"+JSON.stringify(msg)+"</ERROR>");
  });
 });

  // warning: security vulnerability:  parses any file in system!!!!!!
  parser.parseFile(app.settings.recipeRoot + req.params.recipe);

};
