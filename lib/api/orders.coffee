CRUDApi     = require './_crud'
OrdersSvc   = require './../services/orders'
authz       = require './../identity/authz'
loggedIn    = authz.LoggedIn isApi: true
admin       = authz.Admin isApi: true
Roles       = authz.Roles


class OrdersApi

  svc: new OrdersSvc()

  constructor: (app, route) ->
    app.post    "/api/#{route}", loggedIn, @create
    app.get     "/api/admin/#{route}", admin, @adminList
    app.put     "/api/#{route}/:id", admin, @payOut
    app.delete  "/api/#{route}/:id", admin, @delete

  adminList: (req, res) =>
    @svc.getAll (r) -> res.send r


  create: (req, res) =>
    order = _.pick req.body, ['total','requestId']
    order.lineItems = []
    order.company =
      _id: req.body.company._id
      name: req.body.company.name
      contacts: req.body.company.contacts
    order.paymentMethod = req.body.paymentMethod

    toPick = ['_id','userId','name','username','rate','email','pic','paymentMethod']
    for li in req.body.lineItems
      if li.qty > 0
        order.lineItems.push
          type: li.type
          total: li.total
          unitPrice: li.unitPrice
          qty: li.qty
          suggestion:
            _id: li.suggestion._id
            suggestedRate: li.suggestion.suggestedRate
            expert: _.pick li.suggestion.expert, toPick

    @svc.create order, req.user, (r) =>
      if r.payment.responseEnvelope? && r.payment.responseEnvelope.ack is "Failure"
        res.status(400)
      res.send r


  payOut: (req, res) =>
    @svc.payOutToExperts req.params.id, (r) ->
      if r.status? & r.status is 'Failure'
        res.status(400)
      res.send r


  delete: (req, res) =>
    @svc.delete req.params.id, (r) -> res.send r


module.exports = (app) -> new OrdersApi app, 'orders'