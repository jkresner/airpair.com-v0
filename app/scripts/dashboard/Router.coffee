S = require('./../shared/Routers')
SV = require('./../shared/Views')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/dashboard'

  routes:
    'requests': 'requests'

  appConstructor: (pageData, callback) ->
    d =
      requests: new C.Requests()
      orders: new C.Orders()
    v =
      requestsView: new V.RequestsView collection: d.requests, model: @app.session
      callsView: new V.CallsView collection: d.requests, model: @app.session
      ordersView: new V.OrdersView collection: d.orders, model: @app.session

    @resetOrFetch d.requests, pageData.requests
    @resetOrFetch d.orders, pageData.orders

    _.extend d, v

  initialize: (args) ->
    @navTo 'requests'
