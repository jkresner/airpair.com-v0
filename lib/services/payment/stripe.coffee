api_key = cfg.payment.stripe.secretKey
stripe = require('stripe')(api_key)

module.exports = class StripeService
  
  
  constructor: () ->


  createCustomer: (email, token, callback) ->

    stripe.customers.create { email: email, card: token }, (err, customer) => 
      # $log 'err', err, 'customer', customer
      callback customer

   
  createCharge: (order, callback) ->
    order.paymentType = 'paypal'
    customerId = order.payWith.info.customerId

    # Make a charge
    stripe.charges.create { customer: customerId, amount: order.total, currency: "usd" }, (err, charge) => 
      $log 'err', err, 'charge', charge
      
      callback charge