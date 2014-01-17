S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/inbound'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
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
      experts: new C.Experts()
    v =
      requestsView: new V.RequestsView collection: d.requests, model: d.selected
      requestView: new V.RequestView model: d.selected, collection: d.requests, tags: d.tags, experts: d.experts, session: @app.session
      filtersView: new V.FiltersView collection: d.requests
      farmingView: new V.RequestFarmView model: d.selected

    @resetOrFetch d.requests, pageData.requests
    @resetOrFetch d.experts, pageData.experts
    @resetOrFetch d.tags, pageData.tags

    _.extend d, v

  initialize: (args) ->
    @navTo 'list'

  inactive: ->
    $('#list').show()
    @app.requests.url = '/api/admin/requests/inactive'
    @app.requests.fetch()

  request: (id) ->
    if @app.requests.length == 0 then return
    if !id?
      @app.selected.clearAndSetDefaults()
      return
    d = @app.requests.get id
    if !d
      @app.selected.set('_id', id, { silent: true })
      @app.selected.fetch({ reset: true })
      return
    @app.selected.clear { silent: true }
    @app.selected.set d.attributes
