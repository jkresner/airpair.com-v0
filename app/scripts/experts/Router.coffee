S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/experts'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'list'        : 'list'
    'edit'        : 'edit'

  appConstructor: (pageData, callback) ->
    d =
      selected: new M.Expert()
      experts: new C.Experts()
    v =
      expertsView: new V.ExpertsView collection: d.experts, model: d.selected
      expertView: new V.ExpertView el: '#expertPreview', model: d.selected

    @resetOrFetch d.experts, pageData.experts

    _.extend d, v

  initialize: (args) ->
    @navTo 'list'