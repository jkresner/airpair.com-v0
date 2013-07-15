CRUDApi     = require './_crud'
OrdersSvc   = require './../services/orders'
authz       = require './../identity/authz'
loggedIn    = authz.LoggedIn isApi: true
Roles       = authz.Roles


class OrdersApi extends CRUDApi

  svc: new OrdersSvc()

  constructor: (app, route) ->
    app.post  "/api/#{route}", loggedIn, @create
    super app, route

  create: (req, res) =>
    order = _.pick req.body, ['total','requestId']
    order.lineItems = []
    for li in req.body.lineItems
      toPick = ['_id','userId','name','username','rate','email','timezone']

      order.lineItems.push
        type: li.type
        total: li.total
        unitPrice: li.unitPrice
        qty: li.qty
        suggestion:
          _id: li.suggestion._id
          suggestedRate: li.suggestion.suggestedRate
          expert: _.pick li.suggestion.expert, toPick

    @svc.create order, req.user, (r) => res.send r


module.exports = (app) -> new OrdersApi app, 'orders'