authz            = require './../identity/authz'
admin            = authz.Admin isApi: true
MarketingTagsSvc = require './../services/marketingtags'
cSend            = require '../util/csend'

class MarketingTagsApi

  svc: new MarketingTagsSvc()

  constructor: (app, route) ->
    app.post    "/api/#{route}", admin, @create
    app.get     "/api/#{route}", admin, @list
    app.get     "/api/#{route}/:id", admin, @getById
    app.put    "/api/#{route}/:id", admin, @edit
    app.delete  "/api/#{route}/:id", admin, @delete

  create: (req, res, next) =>
    @svc.create req.body, cSend(res, next)

  list: (req, res, next) =>
    @svc.getAll cSend(res, next)

  getById: (req, res, next) =>
    @svc.getById req.params.id, cSend(res, next)

  edit: (req, res, next) =>
    @svc.edit req.body, cSend(res, next)

  delete: (req, res, next) =>
    @svc.delete req.params.id, cSend(res, next)

module.exports = (app) -> new MarketingTagsApi app, 'marketingtags'
