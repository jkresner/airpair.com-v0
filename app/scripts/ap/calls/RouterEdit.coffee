S = require '../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'

module.exports = class Router extends S.AirpairSessionRouter
  # logging: on
  pushStateRoot: '/adm/call'
  routes:
    'edit/:callId': 'edit'

  appConstructor: (pageData, callback) ->
    requestId = pageData.request._id
    d =
      request: new M.Request _id: requestId
      requestCall: new M.RequestCall
      orders: new C.Orders
      video: new M.Video() # model only used to hits video API & shows errors
      videos: new C.Videos() # collection only used to display videolist
    d.requestCall.requestId = requestId
    d.orders.requestId = requestId

    v =
      videosView: new V.VideosView
        model: d.video, collection: d.videos, requestCall: d.requestCall,
      callEditView: new V.CallEditView
        model: d.requestCall, request: d.request, collection: d.orders, videos: d.videos

    @setOrFetch d.request, pageData.request
    @resetOrFetch d.orders, pageData.orders

    _.extend d, v

  edit: (callId) ->
    # populate requestCall with existing data from the request
    selectedCall = _.find @app.request.get('calls'), (c) -> c._id == callId
    @app.requestCall.set selectedCall
