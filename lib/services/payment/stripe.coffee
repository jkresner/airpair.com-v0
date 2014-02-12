api_key = cfg.payment.stripe.secretKey
stripe  = require('stripe')(api_key)


module.exports = class StripeService


  constructor: () ->


  createCustomer: (email, token, callback) ->

    stripe.customers.create { email: email, card: token }, (err, customer) =>
      if err then return callback err
      callback null, customer


  createCharge: (order, callback) ->
    order.paymentType = 'stripe'
    customerId = order.paymentMethod.info.id

    payload = customer: customerId, amount: order.total*100, currency: "usd"

    # Make a charge
    stripe.charges.create payload, (err, charge) =>
      if err then return callback err
      if cfg.isProd
        $log "StripeResponse: ", payload, charge
        winston.log "StripResponse: ", charge
      callback null, charge
