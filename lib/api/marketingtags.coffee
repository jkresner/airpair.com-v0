authz = require './../identity/authz'
admin = authz.Admin isApi: true
MarketingTagsSvc = require './../services/marketingtags'

class MarketingTagsApi

  svc: new MarketingTagsSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}", admin, @list
    app.post    "/api/#{route}", admin, @create
    app.delete  "/api/#{route}/:id", admin, @delete

  create: (req, res, next) =>
    ### TODO validate:
      no duplicates
      {name,type,group} are non-empty strings
    ###
    @svc.create req.body, (e, r) ->
      if e then return next e
      res.send r

  list: (req, res, next) =>
    @svc.getAll (e, r) ->
      if e then return next e
      res.send r

  delete: (req, res, next) =>
    @svc.delete req.params.id, (e, r) ->
      if e then return next e
      res.send r

module.exports = (app) -> new MarketingTagsApi app, 'marketingtags'
