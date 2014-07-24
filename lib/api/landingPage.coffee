api_key    = config.payment.stripe.secretKey
stripe     = require('stripe')(api_key)
mcapi      = require('mailchimp-api');

class LandingPageApi extends require('./_api')

  Svc: require './../services/orders'

  routes: (app, route) ->
    app.post "/api/#{route}/purchase", @ap, @createCustomer # generic, client decides $$
    app.post "/api/#{route}/airconf/promo", @ap, @loggedIn, @airconfPromo
    app.post "/api/#{route}/airconf/order", @ap, @loggedIn, @airconfCreateOrder
    app.post "/api/#{route}/mailchimp/subscribe", @ap, @mailchimpSubscribe

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

  mailchimpSubscribe: =>
    mc = new mcapi.Mailchimp 'b888ee9284cd0d57f425867c0bde3fe0-us7'
    success = (data) => @cbSend(null, data)
    mc.lists.subscribe { id: @data.listId, email: { email: @data.email } }, success, (e) => @cbSend e


  airconfPromo: => @svc.getAirConfPromoRate @data.code, @cbSend
  airconfOrder: => @svc.createAirConfOrder @data, @cbSend
  airconfCreateOrder: => @svc.createAirConfOrder @data, @cbSend


module.exports = (app) -> new LandingPageApi app, 'landing'
