S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  # logging: on

  pushStateRoot: '/@'

  routes:
    ':id': 'index'

  appConstructor: (pageData, callback) ->
    e =
      expert: new M.Expert()
      request: new M.Request()
      tags: new C.Tags()
    v =
      signinView: new V.SigninView()
      # infoFormView: new V.InfoFormView model: d.company, request: d.request
      # requestFormView: new V.RequestFormView model: d.request, tags: d.tags
      # confirmEmailView: new V.ConfirmEmailView model: d.company, request: d.request

    _.extend e, v

  initialize: (args) ->

  index: ->
    # todo
