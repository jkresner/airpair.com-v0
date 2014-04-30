S   = require '../shared/Routers'
SC = require '../shared/Collections'
SM = require '../shared/Models'
C  = require './Collections'
V  = require './Views'



module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/history'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'detail'    : 'detail'

  appConstructor: (pageData, callback) ->
    d =
      # requests: new C.Requests()
      orders: new C.Orders()
    v =
      ordersView: new V.OrdersView collection: d.orders

    @resetOrFetch d.orders
    _.extend d, v

  initialize: (args) ->
    @navTo 'detail'

