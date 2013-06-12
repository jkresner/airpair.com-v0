S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  # logging: on

  pushStateRoot: '/review'

  routes:
    ':id'         : 'detail'
    'detail/:id'  : 'detail'
    ''            : 'empty'

  appConstructor: (pageData, callback) ->
    d = request: new M.Request()
    v = requestView: new V.RequestView( request: d.request, session: @app.session )

    _.extend d, v

  initialize: (args) ->

  empty: ->
    $log 'Router.empty'
    window.location = '/'

  detail: (id) ->
    if !id? then return @empty()

    @app.request.set { '_id': id }, { silent: true }

    $('nav ul').show() if @isAuthenticated()

    if @app.session.id is '5175efbfa3802cc4d5a5e6ed'
      $('nav ul').append("<li><a href='/adm/inbound/#{@app.request.id}'' class='zocial'>request admin</a><li>")

    if !@app.request.get('userId')?
      @app.request.fetch error: => error: @empty