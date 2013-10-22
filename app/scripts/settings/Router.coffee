S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/settings'

  routes:
    ''                : 'payment'    
    'payment'         : 'payment'
    'stripe'          : 'stripe'

  appConstructor: (pageData, callback) ->
    d =
      settings: new M.Settings()
    v =
      paymentSettingsView: new V.PaymentSettingsView model: d.settings
      stripeRegisterView: new V.StripeRegisterView model: d.settings, session: @app.session

    @setOrFetch d.settings, pageData.settings

    Stripe.setPublishableKey pageData.stripePK

    _.extend d, v

  initialize: (args) ->
    @navTo 'payment'

  stripe: ->
    $log 'stripeRegister'
