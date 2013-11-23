S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/schedule'

  routes:
    'new/:id'          : 'new'
    'confirm/:id'      : 'confirm'
    'list/:id'         : 'list'

  appConstructor: (pageData, callback) ->
    requestId = @defaultFragment
      .replace('/new/','')
      .replace('/confirm/','')
      .replace('/list/','')

    d =
      request: new M.Request _id: requestId
      orders: new C.Orders()
    v =
      listView: new V.ListView model: d.request, collection: d.orders


    d.orders.requestId = requestId

    @setOrFetch d.request, pageData.request
    @setOrFetch d.orders, pageData.orders

    _.extend d, v

  initialize: (args) ->

  new: (id) ->

  confirm: (id) ->

  list: (id) ->
