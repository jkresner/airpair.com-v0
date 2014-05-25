
class CompanyApi extends require('./_api')

  Svc: require './../services/companys'

  routes: (app, route) ->
    app.get     "/api/admin/#{route}", @admin, @ap, @list
    app.get     "/api/#{route}/:id", @loggedIn, @ap, @detail
    app.post    "/api/#{route}", @loggedIn, @ap, @create
    app.put     "/api/#{route}/:id", @loggedIn, @ap, @update
    # app.delete  "/api/#{route}/:id", @admin, @ap, @delete


module.exports = (app) -> new CompanyApi app, 'companys'
