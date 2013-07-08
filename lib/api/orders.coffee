CRUDApi     = require './_crud'
OrdersSvc = require './../services/orders'
authz       = require './../identity/authz'
loggedIn    = authz.LoggedIn isApi: true
Roles       = authz.Roles

class OrdersApi extends CRUDApi

  # model: require './../models/request'
  svc: new OrdersSvc()
  # rates: new RatesSvc()

  constructor: (app, route) ->
    app.post  "/api/#{route}", loggedIn, @pay
    super app, route

  pay: (req, res) =>
    @paymentSvc.Pay req.body, (r) =>
      res.send r



module.exports = (app) -> new OrdersApi app,'orders'