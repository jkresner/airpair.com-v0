TagsSvc = require './../services/tags'
authz     = require './../identity/authz'
loggedIn  = authz.LoggedIn isApi:true

class TagsApi

  svc: new TagsSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}", loggedIn, @list
    #app.get     "/api/#{route}/:id", loggedIn, @detail
    app.post    "/api/#{route}", loggedIn, @create
    app.put     "/api/#{route}/:id", loggedIn, @update
    #app.delete  "/api/#{route}/:id", loggedIn, @delete

  create: (req, res) =>
    @svc.create req.body.addMode, req.body, (e, r) ->
      $log 'in create callback', e, r
      if e?
        res.send 400, { errors: { message: e.message } }
      else
        res.send r

  update: (req, res) =>
    $log 'updating', req.params.id, req.body
    @svc.update req.params.id, req.body, (r) ->
      res.send r


  list: (req, res) => @svc.getAll (r) -> res.send r


module.exports = (app) -> new TagsApi app,'tags'