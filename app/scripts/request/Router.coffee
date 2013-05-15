exports = {}
SRouters = require('./../shared/All').Routers
M = require './Models'
C = require './Collections'
V = require './Views'


# on page we construct our app/router with data from the page
$ -> if RequestRouter? then window.initRouterWithPageData RequestRouter


class RequestRouter extends SRouters.AirpairSessionRouter

  pushStateRoot: '/find-an-expert'

  logging: on

  routes:
    'welcome'       : 'welcome'
    'info'          : 'info'
    'request'       : 'request'
    'thanks'        : 'thanks'
    'update/:id'    : 'update'

  appConstructor: (pageData, callback) ->
    d =
      company: new M.Company _id: 'me'
      request: new M.Request()
      tags: new C.Tags()
    v =
      welcomeView: new V.WelcomeView()
      infoFormView: new V.InfoFormView model: d.company, request: d.request
      requestFormView: new V.RequestFormView model: d.request, tags: d.tags

    _.extend d, v

  initialize: (args) ->
    if @app.session.authenticated() then @navTo 'info' else @navTo 'welcome'

  welcome: ->
    @app.welcomeView.render()

  info: ->
    if !@app.session.authenticated() then return @navTo 'welcome'

    @app.company.fetch success: (m, opts, resp) =>
      m.populateFromGoogle @app.session

  request: ->
    if !@app.session.authenticated() then return @navTo 'welcome'

    if @app.tags.length is 0 then @app.tags.fetch()

    @app.request.set
      company: @app.company.attributes

  thanks: ->

  update: (id) ->
    @app.request.set '_id': id
    @app.request.fetch success: (model, opts, resp) =>
      @app.company.set '_id': model.get('company')._id
      @company()


module.exports = RequestRouter