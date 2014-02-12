CompanysSvc = require './../services/companys'
authz       = require './../identity/authz'
loggedIn    = authz.LoggedIn isApi:true
admin       = authz.Admin isApi: true
cSend       = require '../util/csend'

class CompanyApi

  svc: new CompanysSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}/:id", loggedIn, @detail
    app.get     "/api/admin/#{route}", admin, @adminlist
    app.post    "/api/#{route}", loggedIn, @create
    app.put     "/api/#{route}/:id", loggedIn, @update
    app.delete  "/api/#{route}/:id", admin, @delete

  detail: (req, res, next) =>

    search = '_id': req.params.id

    if req.params.id is 'me'
      search = 'contacts.userId': req.user._id

    @svc.searchOne search, cSend(res, next)

  adminlist: (req, res, next) =>
    @svc.getAll cSend(res, next)

  create: (req, res, next) =>
    @svc.create req.body, cSend(res, next)

  update: (req, res, next) =>
    @svc.update req.params.id, req.body, cSend(res, next)

  delete: (req, res, next) =>
    @svc.delete req.params.id, cSend(res, next)


module.exports = (app) -> new CompanyApi app, 'companys'
