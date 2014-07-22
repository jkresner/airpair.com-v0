S = require '../../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  # logging: on

  pushStateRoot: '/airconf-registration'

  routes:
    ''          : 'register'
    'thanks'    : 'thanks'

  appConstructor: (pageData, callback) ->
    {requestId,ticketPrice,pairCredit,paid,confOrder} = pageData.registration

    d =
      registration: new Backbone.Model { paid, pairCredit, hasCard: pageData.hasCard }
      order: new M.Order confOrder
      settings: new M.Settings pageData.settings
      # company: new M.Company _id: 'me'
    v =
      orderView: new V.OrderView model: d.order
      # thankyouView: new V.ThankYouView( model: d.order )

    if !d.registration.get('hasCard')
      $log 'adding stripe thing'
      v.stripeRegisterView = new V.StripeRegisterView model: d.settings, session: @app.session
      v.stripeRegisterView.$el.show()
      Stripe.setPublishableKey pageData.stripePK

    if !confOrder?
      d.order.set { requestId, total:ticketPrice }

    # d.company.fetch success: (m, opts, resp) =>
      # m.populateFromGoogle @app.session

    _.extend d, v

  initialize: (args) ->
    # $log 'initialize', @app.registration.attributes

    if @app.registration.get('paid')
      @navTo 'thanks'
    else
      if @app.registration.get('hasCard')
        $('#haveCard').show()

  register: (args) ->
    $log 'in register'

  thanks: (args) ->

