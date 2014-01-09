admin = authz.Admin isApi: true
authz = require './../identity/authz'
SourcesSvc = require './../services/sources'

class SourcesApi

  svc: new SourcesSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}", admin, @list
    app.post    "/api/#{route}", admin, @create

  create: (req, res, next) =>
    ### todo validate:
      not duplicate
      {name,type,group} are non-empty strings
    ###
    @svc.create req.body, (e, r) ->
      if e then return next e
      res.send r

  list: (req, res, next) =>
    @svc.getAll (e, r) ->
      if e then return next e
      res.send r

module.exports = (app) -> new SourcesApi app, 'sources'
