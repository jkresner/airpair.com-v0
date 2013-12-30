S = require '../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'

module.exports = class Router extends S.AirpairSessionRouter
  # logging: on
  pushStateRoot: '/adm'

  routes:
    'schedule/:requestId': 'schedule'
    'schedule/:requestId/call/:callId': 'edit'

  appConstructor: (pageData, callback) ->
    # TODO: better way?
    re = new RegExp('^/schedule\/(?:([^\/]+))', 'i')
    matches = @defaultFragment.match re
    requestId = matches[1]

    re = new RegExp('call\/(?:([^\/]+?))$', 'i')
    matches = @defaultFragment.match re
    if matches
      callId = matches[1]

    console.log('rid', requestId, 'cid', callId)

    d =
      request: new M.Request _id: requestId
      requestCall: new M.RequestCall requestId: requestId
      orders: new C.Orders
    d.orders.requestId = requestId # used by model get orders for the request
    d.request.set 'callId', callId
    v =
      scheduleFormView: new V.ScheduleFormView
        model: d.requestCall, request: d.request, collection: d.orders
      scheduledView: new V.ScheduledView
        model: d.requestCall, request: d.request, collection: d.orders

    @setOrFetch d.request, pageData.request
    @setOrFetch d.orders, pageData.orders

    _.extend d, v
  edit: (requestId, callId) ->
    $('#edit').show() # TODO I shouldnt need to write this
