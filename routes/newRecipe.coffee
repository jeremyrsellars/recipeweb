module.exports = (req, res) ->
   res.render 'new', {title:"new recipe", body:"recipe", recipe:"recipe", layout:true}
