S = require '../../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'

module.exports = class Router extends S.AirpairSessionRouter
  # logging: on
  pushStateRoot: '/schedule'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    ':requestId/edit/:callId': 'edit'
    ':requestId/edit/:callId': 'edit'
    ':requestId': 'schedule'

  appConstructor: (pageData, callback) ->
    requestId = pageData.request._id
    d =
      request: new M.Request _id: requestId
      requestCall: new M.RequestCall()
      orders: new C.Orders()
    d.requestCall.requestId = requestId
    d.orders.requestId = requestId

    v =
      callsView: new V.CallsView model: d.request
      scheduleView: new V.ScheduleView
        model: d.requestCall, request: d.request, collection: d.orders
      # videosView: new V.VideosView
        # model: d.video, collection: d.videos, requestCall: d.requestCall,
      # callEditView: new V.CallEditView
        # model: d.requestCall, request: d.request, collection: d.orders, videos: d.videos

    @setOrFetch d.request, pageData.request
    @resetOrFetch d.orders, pageData.orders

    _.extend d, v

  schedule: ->
    match = /expertId=((?:[a-z0-9_]*))/i.exec(window.location.search)
    if match
      @app.requestCall.set('expertId', match[1])

  edit: (callId) ->
    # populate requestCall with existing data from the request
    selectedCall = _.find @app.request.get('calls'), (c) -> c._id == callId
    @app.requestCall.set selectedCall
