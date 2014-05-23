Api  = require './_api'

class TagsApi extends Api

  Svc: require './../services/tags'

  routes: (app, route) ->
    app.get     "/api/#{route}", @loggedIn, @ap, @list
    app.post    "/api/#{route}", @loggedIn, @ap, @create
    app.put     "/api/#{route}/:id", @loggedIn, @ap, @update
    app.delete  "/api/#{route}/:id", @loggedIn, @ap, @delete

  create: (req, res, next) =>
    @svc.create req.body.addMode, req.body, (e, r) ->
      if e
        res.send 400, { errors: { message: e.message } }
      else
        res.send r

  update: (req, res, next) =>
    @svc.update req.params.id, req.body, @cbSend

  delete: (req, res, next) =>
    @svc.delete req.params.id, @cbSend

  list: (req, res, next) =>
    @svc.getAll @cbSend


module.exports = (app) -> new TagsApi app, 'tags'
