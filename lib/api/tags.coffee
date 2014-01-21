TagsSvc = require './../services/tags'
authz = require './../identity/authz'
loggedIn = authz.LoggedIn isApi:true
cSend = require '../util/csend'

class TagsApi

  svc: new TagsSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}", loggedIn, @list
    #app.get     "/api/#{route}/:id", loggedIn, @detail
    app.post    "/api/#{route}", loggedIn, @create
    app.put     "/api/#{route}/:id", loggedIn, @update
    app.delete  "/api/#{route}/:id", loggedIn, @delete

  create: (req, res, next) =>
    @svc.create req.body.addMode, req.body, (e, r) ->
      if e?
        res.send 400, { errors: { message: e.message } }
      else
        res.send r

  update: (req, res, next) =>
    @svc.update req.params.id, req.body, cSend(res, next)

  delete: (req, res, next) =>
    @svc.delete req.params.id, cSend(res, next)

  list: (req, res, next) =>
    @svc.getAll cSend(res, next)


module.exports = (app) -> new TagsApi app, 'tags'
