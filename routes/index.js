String.prototype.endsWith = function(str)
{
    var lastIndex = this.lastIndexOf(str);
    return (lastIndex != -1) && (lastIndex + str.length == this.length);
}

/*
 * GET home page.
 */

var fs = require('fs');

exports.about = function(req, res){
  res.render('about', {title:'About Hungry Adelaide Recipes'});
};

exports.legal = function(req, res){
  res.render('legal', {title:'Legal - Hungry Adelaide Recipes'});
};

exports.index = function(req, res){
  fs.readdir(app.settings.recipeRoot, function (err, aFiles) {
    var url = require('url').parse(req.url);
    var filterWords;
    var query = '';
    
    if (url.query && url.query != '')
    {
       console.log(url.query);
       var querystring = require('querystring').parse(url.query);
       if (querystring.p)
       {
          filterWords = querystring.p.split(/[+ ]|%20/);
          query = querystring.p;
       }
       console.log(filterWords);
    }

    var recipes = new Array ();
    for (var i = 0; i < aFiles.length; i++)
    {
      var f = aFiles[i]
      if (!f.endsWith('.recipe'))
        continue;
      if (filterWords)
      {
        var add = true;
        for (var w = 0; w < filterWords.length; w++)
        {
           var word = filterWords[w];
           //console.log ('does ' + f + ' contain ' + word + '?');
           var result = f.match(new RegExp(word, "i"));
           if (!result)
           {
              add = false;
              break;
           }
        }

        if (!add)
          continue;
      }
      recipes.push ({Name:f});
    }
    res.render(
      'index',
      {
         title:'Hungry Adelaide Recipes',
         recipes: recipes,
         p : query,
         path : app.settings.recipeRoot,
      });
  });

};

