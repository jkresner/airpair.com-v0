S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/book'

  routes:
    'none'  : 'none'
    ':id'   : 'detail'


  appConstructor: (pageData, callback) ->
    d =
      expert: new M.Expert()
      request: new M.Request()
      tags: new C.Tags()
    v =
      expertView: new V.ExpertView model: d.expert
      # requestView: new V.RequestView()
      # signinView: new V.SigninView()

    @setOrFetch d.expert, pageData.expert

    _.extend d, v

  initialize: (args) ->

  detail: (id) ->
    if !@app.expert.id? then return @none()
    $('#detail').show()


