
class ExpertApi extends require('./_api')

  Svc: require './../services/experts'

  routes: (app, route) ->
    app.get  "/api/#{route}", @admin, @ap, @list
    app.get  "/api/#{route}/:id", @loggedIn, @ap, @detail
    app.post "/api/#{route}", @loggedIn, @ap, @create
    app.put  "/api/#{route}/:id", @admin, @ap, @update


module.exports = (app) -> new ExpertApi app, 'experts'
