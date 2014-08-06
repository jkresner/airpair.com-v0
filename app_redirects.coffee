
module.exports = (app, render) ->

  # Preserves query string (_utm params etc.)
  redirect = (origin, destination) ->
    app.get origin, (req, r) -> r.redirect req.url.replace(origin,destination)

  # can later move all this into non code dependent storage
  redirect '/workshops', '/airconf2014'

  redirect '/airconf/spreadsheets-graph-databases', '/neo4j/workshops/spreadsheets-graph-databases' # link from neo4j website
  redirect '/solr/workshops/discovering-your-inned-search-engine', '/solr/workshops/discovering-your-inner-search-engine'
  redirect '/php/workshops/php-town-crier', '/php/workshops/breaking-up-with-lamp'
