
class CompanyApi extends require('./_api')

  Svc: require './../services/companys'

  routes: (app) ->
    app.get     "/admin/companys", @admin, @ap, @list
    app.get     "/companys/:id", @loggedIn, @ap, @detail
    app.post    "/companys", @loggedIn, @ap, @create
    app.put     "/companys/:id", @loggedIn, @ap, @update

module.exports = (app) -> new CompanyApi(app)
