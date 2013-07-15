DomainService   = require './_svc'
PaypalAdaptiveSvc = require './../services/payment/paypal-adaptive'
mongoose = require 'mongoose'

module.exports = class OrdersService extends DomainService

  model: require './../models/order'
  paymentSvc: new PaypalAdaptiveSvc()

  create: (order, user, callback) ->
    order._id = new mongoose.Types.ObjectId;
    order.userId = user._id
    order.email = user.google._json.email
    order.fullName = user.google._json.name

    # ? if order.email != user.primaryEmail
    # update user's primary email

    # 3rd party invoice integration ?
    order.invoice = {}

    @paymentSvc.Pay order, (r) =>
      order.payment = r
      winston.log "order.payment", order
      new @model( order ).save (e, rr) ->
        if e?
          $log "order.save.error", e, order.payment
          winston.errror "order.save.error", e
        callback rr

  markPaid: (orderId, paymentDetail, callback) ->
    # perhaps use get payment details call instead of hack status
    # should check for userId too

    ups = paymentStatus: 'paid'

    @update orderId, ups, callback