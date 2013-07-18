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
    'book/:id'    : 'book'
    ''            : 'empty'

  appConstructor: (pageData, callback) ->
    d =
      request: new M.Request _id: @defaultFragment
      order: new M.Order()
      settings: new M.Settings()
    v =
      requestView: new V.RequestView( request: d.request, settings: d.settings, session: @app.session )

    opts =
      error: => @empty(v.requestView)
      success: =>
        if d.request.isCustomer(@app.session)
          v.bookView = new V.BookView( model: d.order, request: d.request, session: @app.session, isProd: pageData.isProd ).render()

    @setOrFetch d.request, pageData.request, opts

    if @app.session.authenticated()
      @setOrFetch d.settings, pageData.settings

    _.extend d, v

  initialize: (args) ->

  empty: (v) =>
    if !v? then v = @app.requestView
    v.$el.replaceWith '<div id="empty"><h2>Could not retrieve request</h2></div>'

  detail: (id) ->
    if !id? then return @empty()

    $('nav ul').show() if @isAuthenticated()

    if @app.session.id is '5175efbfa3802cc4d5a5e6ed'
      $('nav ul').append("<li><a href='/adm/inbound/#{@app.request.id}'' class='zocial'>request admin</a><li>")

  book: (id) ->
    if !id? then return @empty()