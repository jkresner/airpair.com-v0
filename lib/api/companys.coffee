CompanysSvc = require './../services/companys'
authz       = require './../identity/authz'
loggedIn    = authz.LoggedIn isApi:true
admin       = authz.Admin isApi: true


class CompanyApi

  svc: new CompanysSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}/:id", loggedIn, @detail
    app.get     "/api/admin/#{route}", admin, @adminlist
    app.post    "/api/#{route}", loggedIn, @create
    app.put     "/api/#{route}/:id", loggedIn, @update
    app.delete  "/api/#{route}/:id", admin, @delete

  detail: (req, res) =>

    search = '_id': req.params.id

    if req.params.id is 'me'
      search = 'contacts.userId': req.user._id

    @svc.searchOne search, (r) -> res.send r

  adminlist: (req, res) => @svc.getAll (r) -> res.send r

  create: (req, res) =>
    @svc.create req.body, (r) -> res.send r

  update: (req, res) =>
    @svc.update req.params.id, req.body, (r) -> res.send r

  delete: (req, res) =>
    @svc.delete req.params.id, (r) -> res.send r


module.exports = (app) -> new CompanyApi app, 'companys'