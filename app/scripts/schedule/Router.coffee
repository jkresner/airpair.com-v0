S = require '../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'

module.exports = class Router extends S.AirpairSessionRouter
  # logging: on
  pushStateRoot: '/adm'
  routes:
    'schedule/:requestId/call/:callId': 'edit'
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
      scheduleFormView: new V.ScheduleFormView
        model: d.requestCall, request: d.request, collection: d.orders
      scheduledView: new V.ScheduledView
        model: d.requestCall, request: d.request, collection: d.orders

    @setOrFetch d.request, pageData.request
    @resetOrFetch d.orders, pageData.orders

    _.extend d, v

  edit: (requestId, callId) ->
    @editpage = true
    $('.route').hide()
    $('#edit').show()

    # populate requestCall with existing data from the request
    selectedCall = _.find @app.request.get('calls'), (c) -> c._id == callId
    @app.requestCall.set selectedCall
