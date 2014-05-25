
class OrdersApi extends require('./_api')

  Svc: require './../services/orders'

  routes: (app, route) ->
    app.post    "/api/#{route}", @loggedIn, @ap, @create
    app.get     "/api/admin/#{route}", @admin, @ap, @list
    app.get     "/api/#{route}/request/:id", @admin, @ap, @getByRequestId
    app.get     "/api/#{route}/me", @loggedIn, @ap, @getByMe
    app.put     "/api/#{route}/:id", @admin, @ap, @update
    app.delete  "/api/#{route}/:id", @admin, @ap, @delete


  getByRequestId: (req, res) => @svc.getByRequestId req.params.id, @cbSend
  getByMe: (req, res) => @svc.getByUserId req.user._id, @cbSend

  create: (req, res) =>
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


  update: (req, res) =>
    if req.body.payoutOptions
      opts = req.body.payoutOptions
      delete req.body.payoutOptions
      return @svc.payOut req.params.id, opts, req.body, cSend(res, next)
    if req.body.swapExpert
      {suggestion} = req.body.swapExpert
      return @svc.swapExpert req.params.id, req.user, suggestion, cSend(res, next)
    return res.send(400, 'updating orders not yet implemented')


module.exports = (app) -> new OrdersApi app, 'orders'
