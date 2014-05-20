Api         = require './_api'
CompanysSvc = require './../services/companys'


class CompanyApi extends Api

  Svc: CompanysSvc

  routes: (app, route) ->
    app.get     "/api/#{route}/:id", @loggedIn, @ap, @detail
    app.get     "/api/admin/#{route}", @admin, @ap, @adminlist
    app.post    "/api/#{route}", @loggedIn, @ap, @create
    app.put     "/api/#{route}/:id", @loggedIn, @ap, @update
    app.delete  "/api/#{route}/:id", @admin, @ap, @delete

  detail: (req, res) =>
    search = '_id': req.params.id

    if req.params.id is 'me'
      search = 'contacts.userId': req.user._id

    @svc.searchOne search, null, @cbSend

  adminlist: (req, res) => @svc.getAll @cbSend

  create: (req, res) => @svc.create @data, @cbSend

  update: (req, res) => @svc.update req.params.id, @data, @cbSend

  delete: (req, res) => @svc.delete req.params.id, @cbSend


module.exports = (app) -> new CompanyApi app, 'companys'
