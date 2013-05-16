S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/dashboard'

  routes:
    'requests'       : 'requests'

  appConstructor: (pageData, callback) ->
    d =
      requests: new C.Requests()
    v =
      requestsView: new V.RequestsView collection: d.requests, model: @app.session

    @resetOrFetch d.requests, pageData.requests

    _.extend d, v


  initialize: (args) ->
    @navTo 'requests'


# on jQuery ready, construct a router instance w data injected from the page
$ -> window.initRouterWithPageData Router