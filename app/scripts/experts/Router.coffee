S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/experts'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'list'        : 'list'
    'edit/:id'    : 'edit'

  appConstructor: (pageData, callback) ->
    d =
      selected: new M.Expert()
      experts: new C.Experts()
      tags: new C.Tags()
    v =
      expertsView: new V.ExpertsView collection: d.experts, model: d.selected
      expertView: new V.ExpertView collection: d.experts, model: d.selected, tags: d.tags

    @resetOrFetch d.experts, pageData.experts

    _.extend d, v

  initialize: (args) ->
    @navTo 'list'

  edit: (id) ->
    if @app.tags.length is 0 then @app.tags.fetch()
    @app.selected.set { '_id': id }, { silent: true }
    @app.selected.fetch()
