
class TagsApi extends require('./_api')

  Svc: require './../services/tags'

  routes: (app, route) ->
    app.get     "/api/#{route}", @loggedIn, @ap, @list
    app.post    "/api/#{route}", @loggedIn, @ap, @create
    app.put     "/api/#{route}/:id", @loggedIn, @ap, @update
    app.delete  "/api/#{route}/:id", @loggedIn, @ap, @delete


  create: (req) => svc.create req.body.addMode, req.body, @cbSend


module.exports = (app) -> new TagsApi app, 'tags'
