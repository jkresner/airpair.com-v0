S = require '../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'

module.exports = class Router extends S.AirpairSessionRouter
  # logging: on
  pushStateRoot: '/calls'
  routes:
    '': 'list'

  appConstructor: (pageData, callback) ->
    d =
      requestCall: new M.RequestCall
      calls: new C.RequestCalls

    v =
      callsView: new V.CallsView
        model: d.requestCall, collection: d.calls

    @resetOrFetch d.calls, pageData.calls

    _.extend d, v

  list: ->
