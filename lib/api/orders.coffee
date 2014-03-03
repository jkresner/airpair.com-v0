CRUDApi   = require './_crud'
OrdersSvc = require '../services/orders'
authz     = require '../identity/authz'
loggedIn  = authz.LoggedIn isApi: true
admin     = authz.Admin isApi: true
roles     = require '../identity/roles'
cSend     = require '../util/csend'
Request   = require '../models/request'

class OrdersApi

  svc: new OrdersSvc()

  constructor: (app, route) ->
    app.post    "/api/#{route}", loggedIn, @create
    app.get     "/api/admin/#{route}", admin, @adminList
    app.get     "/api/#{route}/request/:id", loggedIn, @getByRequestId
    app.put     "/api/#{route}/:id", admin, @update
    app.delete  "/api/#{route}/:id", admin, @delete

  adminList: (req, res, next) =>
    @svc.getAll cSend(res, next)

  getByRequestId: (req, res, next) =>
    # TODO admins can view everything, users can only view their own
    @svc.getByRequestId req.params.id, cSend(res, next)

  create: (req, res, next) =>
    order = _.pick req.body, ['total','requestId']
    order.lineItems = []
    order.company =
      _id: req.body.company._id
      name: req.body.company.name
      contacts: req.body.company.contacts
    order.paymentMethod = req.body.paymentMethod
    order.utm = req.body.utm

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

    @svc.create order, req.user, (e, r) =>
      if e then return next e
      if r.payment.responseEnvelope? && r.payment.responseEnvelope.ack is "Failure"
        res.status(400)
      res.send r


  update: (req, res, next) =>
    if req.body.payoutOptions
      opts = req.body.payoutOptions
      delete req.body.payoutOptions
      return @svc.payOut req.params.id, opts, req.body, (e, r) ->
        if e && e.status then return res.send(400, e) # backbone will render errors
        if e then return next e
        return res.send r
    return res.send(400, 'updating orders not yet implemented')


  delete: (req, res, next) =>
    @svc.delete req.params.id, cSend(res, next)


module.exports = (app) -> new OrdersApi app, 'orders'
