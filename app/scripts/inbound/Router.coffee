S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/inbound'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    ''             : 'list'
    'list'         : 'list'
    'inactive'     : 'inactive'
    'request/:id'  : 'request'
    'farm/:id'     : 'farm'
    ':id'          : 'request'

  appConstructor: (pageData, callback) ->
    d =
      selected: new M.Request()
      requests: new C.Requests()
      tags: new C.Tags()
      marketingTags: new C.MarketingTags()
      experts: new C.Experts()
      orders: new C.Orders()
    v =
      requestsView: new V.RequestsView collection: d.requests, model: d.selected
      requestView: new V.RequestView
        model: d.selected
        collection: d.requests
        tags: d.tags
        marketingTags: d.marketingTags
        experts: d.experts
        orders: d.orders
        session: @app.session
      filtersView: new V.FiltersView collection: d.requests
      farmingView: new V.RequestFarmView model: d.selected

    @resetOrFetch d.requests, pageData.requests
    @resetOrFetch d.experts, pageData.experts
    @resetOrFetch d.tags, pageData.tags
    @resetOrFetch d.marketingTags, pageData.marketingTags

    _.extend d, v

  list: ->
    $('#list').show()

  inactive: ->
    @list()
    @app.requests.url = '/api/admin/requests/inactive'
    @app.requests.fetch()

  request: (id) ->
    if !id?
      @app.selected.clearAndSetDefaults()
      return

    # load orders for the request
    if @app.orders.requestId != id
      @app.orders.requestId = id
      @app.orders.fetch()

    # navigating from /farm to this page shouldn't refresh data
    if @app.selected.id == id then return

    route = $('#request')
    route.hide()

    # always fetch it b/c we want freshest data
    @app.selected.set('_id', id, { silent: true })
    @app.selected.fetch reset: true, success: => route.show()
