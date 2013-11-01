S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  # logging: on

  pushStateRoot: '/find-an-expert'

  routes:
    'welcome'       : 'welcome'
    'info'          : 'info'
    'request'       : 'request'
    'confirm'       : 'confirm'
    'thanks'        : 'thanks'
    'edit/:id'      : 'edit'

  appConstructor: (pageData, callback) ->
    d =
      company: new M.Company _id: 'me'
      request: new M.Request()
      tags: new C.Tags()
    v =
      welcomeView: new V.WelcomeView()
      infoFormView: new V.InfoFormView model: d.company, request: d.request
      requestFormView: new V.RequestFormView model: d.request, tags: d.tags
      confirmEmailView: new V.ConfirmEmailView model: d.company, request: d.request

    _.extend d, v

  initialize: (args) ->
    if @isAuthenticated() then @navTo 'info' else @navTo 'welcome'

  welcome: ->
    @app.welcomeView.render()

  info: ->
    if !@isAuthenticated() then return @navTo 'welcome'

    if @app.company.id == 'me'
      @app.company.fetch success: (m, opts, resp) =>
        m.populateFromGoogle @app.session

  request: ->
    if !@isAuthenticated() then return @navTo 'welcome'

    if @app.tags.length is 0 then @app.tags.fetch()

    @app.request.set
      company: @app.company.attributes

  edit: (id) ->
    if !@app.request.id?
      @app.request.set '_id': id
      @app.request.fetch success: (model, opts, resp) =>
        @app.company.set '_id': model.get('company')._id
        @info()
