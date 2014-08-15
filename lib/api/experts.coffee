class ExpertApi extends require('./_api')

  Svc: require('./../services/experts')

  routes: (app) ->
    app.get  "/experts", @admin, @ap, @list
    app.get  "/experts/:id", @loggedIn, @ap, @detail
    app.get  "/experts/request/:id", @loggedIn, @ap, @detailOnRequest
    app.post "/experts", @loggedIn, @ap, @create
    app.put  "/experts/:id", @loggedIn, @ap, @update

  detailOnRequest: (req) => @svc.detailOnRequest req.params.id, @cbSend


module.exports = (app) -> new ExpertApi(app)
