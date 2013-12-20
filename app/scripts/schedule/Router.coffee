S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter
  # logging: on
  pushStateRoot: '/adm'

  routes:
    'schedule/:id': 'schedule'

  appConstructor: (pageData, callback) ->
    # todo: better way?
    id = @defaultFragment.substring(@defaultFragment.lastIndexOf('/') + 1)
    d =
      request: new M.Request _id: id
      requestCall: new M.RequestCall requestId: id
      orders: new C.Orders
    d.orders.requestId = id
    v =
      scheduleFormView: new V.ScheduleFormView
        model: d.requestCall, request: d.request, collection: d.orders
      # scheduledView: new V.ScheduledView model: d.request


    @setOrFetch d.request, pageData.request
    @setOrFetch d.orders, pageData.orders

    _.extend d, v
