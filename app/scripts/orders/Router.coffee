S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/orders'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'list'    : 'list'
    'edit/:id': 'edit'

  appConstructor: (pageData, callback) ->
    d =
      selected: new M.Order()
      orders: new C.Orders()
    v =
      ordersView: new V.OrdersView collection: d.orders, model: d.selected
      orderView: new V.OrderView model: d.selected
      filtersView: new V.FiltersView collection: d.orders

    @resetOrFetch d.orders, pageData.experts
    _.extend d, v

  initialize: (args) ->
    @navTo 'list'

  edit: (id) ->
    if @app.orders.length == 0 then return

    if !id?
      return
    else
      d = _.find @app.orders.models, (m) -> m.get('_id').toString() == id
      if !d? then return @navigate '#', true
      else
        @app.selected.clear { silent: true }
        @app.selected.set d.attributes

