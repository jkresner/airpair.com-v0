S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/inbound'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'list'         : 'list'
    'request/:id'  : 'request'
    'closed'       : 'closed'
    'canceled'     : 'canceled'

  appConstructor: (pageData, callback) ->
    d =
      selected: new M.Request()
      requests: new C.Requests()
      tags: new C.Tags()
      experts: new C.Experts()
    v =
      requestsView: new V.RequestsView collection: d.requests, model: d.selected
      requestView: new V.RequestView model: d.selected, collection: d.requests, tags: d.tags, experts: d.experts

    @resetOrFetch d.requests, pageData.requests
    @resetOrFetch d.tags, pageData.tags
    @resetOrFetch d.experts, pageData.experts

    _.extend d, v

  initialize: (args) ->
    @navTo 'list'

  request: (id) ->

    if !id?
      @app.selected.clearAndSetDefaults()
    else
      d = _.find @app.requests.models, (m) -> m.get('_id').toString() == id
      if !d? then return @navigate '#', true
      else
        @app.selected.set d.attributes