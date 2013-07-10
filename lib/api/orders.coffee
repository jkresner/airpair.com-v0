CRUDApi     = require './_crud'
OrdersSvc   = require './../services/orders'
authz       = require './../identity/authz'
loggedIn    = authz.LoggedIn isApi: true
Roles       = authz.Roles


class OrdersApi extends CRUDApi

  # model: require './../models/request'
  svc: new OrdersSvc()
  # rates: new RatesSvc()

  constructor: (app, route) ->
    app.post  "/api/#{route}", loggedIn, @create
    super app, route

  create: (req, res) =>
    @svc.create req.body, (r) => res.send r


module.exports = (app) -> new OrdersApi app, 'orders'