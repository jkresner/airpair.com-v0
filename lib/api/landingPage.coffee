api_key    = config.payment.stripe.secretKey
stripe     = require('stripe')(api_key)

class LandingPageApi extends require('./_api')

  Svc: require './../services/orders'

  routes: (app, route) ->
    app.post "/api/#{route}/bsa02/purchase", @ap, @createCustomer
    app.post "/api/#{route}/airconf/promo", @ap, @airconfPromo
    app.post "/api/#{route}/airconf/order", @ap, @airconfCreateOrder

  # Create customer, return customer to client, then charge customer.
  createCustomer: (req, res, next) =>
    stripe.customers.create {email: req.body.email, card: req.body.stripeToken.id}, (err, customer) =>
      if err
        console.warn err
        return res.send status: "error", error: err
      res.send
        status: "success"
        customer: customer
      @chargeCustomer customer.id, req.body.stripeCharge.amount

  # Charge a customer given a customer id and amount.
  chargeCustomer: (customerId, amount) =>
    stripe.charges.create
      amount: amount
      currency: "USD"
      customer:customerId
    , (err, charge) ->
      if err then console.log "ERROR - chargeCustomer failed"
      console.log "customer charged #{amount}"


  # Charge a customer given a customer id and amount.
  airconfPromo: => @svc.getAirConfPromoRate @data.code, @cbSend
  airconfOrder: => @svc.createAirConfOrder @data, @cbSend
  airconfCreateOrder: => @svc.createAirConfOrder @data, @cbSend


module.exports = (app) -> new LandingPageApi app, 'landing'
