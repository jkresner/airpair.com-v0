S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  # logging: on

  pushStateRoot: '/payment/register-stripe'

  routes:
    'stripe'            : 'stripe'

  appConstructor: (pageData, callback) ->
    d =
      settings: new M.Settings()
    v = {}
      # registerView: new V.RegisterView model: d.settings, session: @app.session

    if @app.session.authenticated()
      @setOrFetch d.settings, pageData.settings

    Stripe.setPublishableKey pageData.pk

    _.extend d, v

  initialize: (args) ->
    @routeTo 'stripe'