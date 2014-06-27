S = require '../../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/experts'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    ''            : 'list'
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

    if @defaultFragment == ''
      @resetOrFetch d.experts, pageData.experts

    _.extend d, v


  list: (args) ->
    if @app.experts.length is 0 then @app.experts.fetch {reset:true}


  edit: (id) ->
    @app.selected.silentReset { '_id': id }
    @app.selected.fetch()
    @app.selected.trigger 'change:bookMe'
    if @app.tags.length is 0 then @app.tags.fetch {reset:true}
