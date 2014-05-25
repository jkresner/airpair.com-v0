
class ExpertApi extends require('./_api')

  Svc: require './../services/experts'

  routes: (app, route) ->
    app.get  "/api/#{route}", @admin, @ap, @list
    app.post "/api/#{route}", @loggedIn, @ap, @create
    app.put  "/api/#{route}/:id", @admin, @ap, @list


module.exports = (app) -> new ExpertApi app, 'experts'
