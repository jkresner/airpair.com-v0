class ExpertApi extends require('./_api')

  Svc: require('./../services/experts')

  routes: (app, route) ->
    app.get  "/api/#{route}/automatch/tags/:tags", @loggedIn, @ap, @automatch
    app.get  "/api/#{route}", @admin, @ap, @list
    app.get  "/api/#{route}/:id", @loggedIn, @ap, @detail
    app.get  "/api/#{route}/request/:id", @loggedIn, @ap, @detailOnRequest
    app.post "/api/#{route}", @loggedIn, @ap, @create
    app.put  "/api/#{route}/:id", @loggedIn, @ap, @update


  automatch: (req) => @svc.automatch( req.params.tags, @cbSend )

  detailOnRequest: (req) => @svc.detailOnRequest req.params.id, @cbSend


module.exports = (app) -> new ExpertApi app, 'experts'
