S   = require '../shared/Routers'
SC = require '../shared/Collections'
C  = require './Collections'
V  = require './Views'



module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/history'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'detail'    : 'detail'

  appConstructor: (pageData, callback) ->
    d =
      requests: new C.Requests()
      orders: new C.Orders()
    v =
      ordersView: new V.OrdersView collection: d.orders
      callsView: new V.CallsView collection: d.requests, isAdmin: pageData.isAdmin

    @resetOrFetch d.orders, pageData.orders
    @resetOrFetch d.requests, pageData.requests
    _.extend d, v

  initialize: (args) ->
    @navTo 'detail'

