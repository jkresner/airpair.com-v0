class LandingPageApi extends require('./_api')

  Svc: require('../services/orders')
  Chimp: require('../mail/chimp')
  AirConfDiscounts: require('../services/airConfDiscounts')
  Stripe: require('stripe')(config.payment.stripe.secretKey)

  routes: (app, route) ->
    app.post "/api/#{route}/airconf/order", @ap, @loggedIn, @airconfCreateOrder
    app.post "/api/#{route}/airconf/promo", @ap, @loggedIn, @airconfPromoLookup
    app.post "/api/#{route}/mailchimp/subscribe", @ap, @mailchimpSubscribe
    app.post "/api/#{route}/purchase", @ap, @createCustomer # generic, client decides $$

  airconfCreateOrder: =>
    @svc.createAirConfOrder @data, @cbSend

  airconfOrder: =>
    @svc.createAirConfOrder @data, @cbSend

  airconfPromoLookup: =>
    @AirConfDiscounts.lookup @data.code, (err, result) =>
      if result?.valid
        @cbSend(null, result)
      else if not result?.valid
        err.status = 404
        @cbSend(err)
      else
        @cbSend(err)

  # Create customer, return customer to client, then charge customer.
  createCustomer: (req, res, next) =>
    @Stripe.customers.create {email: req.body.email, card: req.body.stripeToken.id}, (err, customer) =>
      if err
        console.warn err
        return res.send status: "error", error: err
      res.send
        status: "success"
        customer: customer
      @chargeCustomer customer.id, req.body.stripeCharge.amount

  # Charge a customer given a customer id and amount.
  chargeCustomer: (customerId, amount) =>
    @Stripe.charges.create
      amount: amount
      currency: "USD"
      customer:customerId
    , (err, charge) ->
      if err then console.log "ERROR - chargeCustomer failed"
      console.log "customer charged #{amount}"

  mailchimpSubscribe: =>
    @Chimp.subscribe config.mailchimp.airconfListId, @data.email, { Paid: 'No' }, @cbSend


module.exports = (app) -> new LandingPageApi app, 'landing'
