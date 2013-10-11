api_key = cfg.payment.stripe.secretKey
stripe = require('stripe')(api_key)

module.exports = class StripeService
  constructor: () ->

  createCustomer: (email, token, callback) ->

    stripe.customers.create { email: email, card: token }, (err, customer) => 
      $log 'err', err, 'customer', customer
      callback customer
   
  createCharge: (usr, charge, token, callback) ->
  
    # Update settings 
    stripe.charges.create { email: 'foobar@example.org' }, callback