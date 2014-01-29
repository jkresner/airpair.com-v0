S = require '../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'

module.exports = class Router extends S.AirpairSessionRouter
  # logging: on
  pushStateRoot: '/adm/call'
  routes:
    'schedule/:requestId': 'schedule'

  appConstructor: (pageData, callback) ->
    requestId = pageData.request._id
    d =
      request: new M.Request _id: requestId
      requestCall: new M.RequestCall
      orders: new C.Orders
    d.requestCall.requestId = requestId
    d.orders.requestId = requestId

    v =
      callScheduleView: new V.CallScheduleView
        model: d.requestCall, request: d.request, collection: d.orders

    @setOrFetch d.request, pageData.request
    @resetOrFetch d.orders, pageData.orders

    _.extend d, v
