S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/settings'

  routes:
    ''        : 'settings'

  appConstructor: (pageData, callback) ->
    d =
      settings: new M.Settings()
    v =
      paymentSettingsView: new V.PaymentSettingsView model: d.settings

    @setOrFetch d.settings, pageData.settings

    _.extend d, v

  initialize: (args) ->