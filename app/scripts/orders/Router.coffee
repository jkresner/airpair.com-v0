S   = require '../shared/Routers'
SC = require '../shared/Collections'
SM = require '../shared/Models'
M  = require './Models'
C  = require './Collections'
V  = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/orders'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'list'        : 'list'
    'edit/:id'    : 'edit'

  appConstructor: (pageData, callback) ->
    d =
      selected: new M.Order()
      orders: new C.Orders()
      marketingTags: new SC.MarketingTags()
      request: new SM.Request()
      dummyRequest: new SM.Request marketingTags: []
    v =
      ordersView: new V.OrdersView collection: d.orders, model: d.selected
      orderView: new V.OrderView model: d.selected, request: d.request
      filtersView: new V.FiltersView
        collection: d.orders,
        marketingTags: d.marketingTags,
        dummyRequest: d.dummyRequest

    @resetOrFetch d.orders, pageData.orders
    @resetOrFetch d.marketingTags, pageData.marketingTags
    _.extend d, v

  initialize: (args) ->
    @navTo 'list'

  edit: (id) ->
    if !id? then return

    d = _.find @app.orders.models, (m) -> m.get('_id').toString() == id
    if !d? then return @navigate '#', true

    @app.selected.clear { silent: true }
    @app.selected.set d.attributes

    @app.request.clear { silent: true }
    @app.request.set { _id: d.attributes.requestId }, { silent: true }
    @app.request.fetch()

    $('#edit a.request').attr 'href', "/adm/pipeline/#{d.attributes.requestId}"
