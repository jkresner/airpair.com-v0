DomainService   = require './_svc'
PaypalAdaptiveSvc = require './../services/payment/paypal-adaptive'


module.exports = class OrdersService extends DomainService

  model: require './../models/order'
  paymentSvc: new PaypalAdaptiveSvc()

  create: (order, callback) ->

    # ? if order.email != user.primaryEmail
    # update user's primary email

    # 3rd party invoice integration ?

    @paymentSvc.Pay order, (r) =>
      order.payment = r

      new @model( order ).save (e, rr) ->
        callback rr
