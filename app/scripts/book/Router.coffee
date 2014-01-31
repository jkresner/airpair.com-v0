S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/@'

  routes:
    ':id': 'index'

  appConstructor: (pageData, callback) ->
    e =
      expert: new M.Expert()
      request: new M.Request()
      tags: new C.Tags()
    v =
      # signinView: new V.SigninView()

    _.extend e, v

  initialize: (args) ->

  index: (id) ->
    # todo
