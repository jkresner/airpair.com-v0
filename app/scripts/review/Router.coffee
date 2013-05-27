S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  logging: on

  pushStateRoot: '/review'

  routes:
    ':id'         : 'detail'
    'detail/:id'  : 'detail'
    ''            : 'empty'

  appConstructor: (pageData, callback) ->
    d = request: new M.Request()
    v = requestView: new V.RequestView( model: d.request, session: @app.session )
    _.extend d, v

  initialize: (args) ->

  empty: ->
    $log 'Router.empty'
    window.location = '/dashboard'

  detail: (id) ->
    if !id? then return window.location = '/dashboard'

    if !@isAuthenticated()
      @app.request.urlRoot = '/api/requests/pub'

    @app.request.set '_id': id
    @app.request.fetch { error: @empty }