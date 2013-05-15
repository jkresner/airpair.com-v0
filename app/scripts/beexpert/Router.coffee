S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  logging: on

  pushStateRoot: '/be-an-expert'

  routes:
    'welcome'       : 'welcome'
    'connect'       : 'connect'
    'info'          : 'info'
    'thanks'        : 'thanks'

  appConstructor: (pageData, callback) ->
    d =
      expert: new M.Expert _id: 'me'
      tags: new C.Tags()
    v =
      welcomeView: new V.WelcomeView()
      connectView: new V.ConnectView model: d.expert, session: @app.session
      infoFormView: new V.InfoFormView model: d.expert, tags: d.tags
      expertStep1View: new V.ExpertView el: '#expertStep1', model: d.expert
      expertStep2View: new V.ExpertView el: '#expertStep2', model: d.expert

    _.extend d, v

  initialize: (args) ->
    if @isAuthenticated() then @navTo 'connect' else @navTo 'welcome'

  welcome: ->
    @app.welcomeView.render()

  connect: ->
    if !@isAuthenticated() then return @navTo 'welcome'

    @app.expert.fetch success: (model, opts, resp) =>
      @app.connectView.render()

  info: ->
    if !@isAuthenticated() then return @navTo 'welcome'

    # If we haven't got the user yet
    if @app.expert.id is 'me'
      return @navTo 'connect'

    if @app.tags.length is 0 then @app.tags.fetch()