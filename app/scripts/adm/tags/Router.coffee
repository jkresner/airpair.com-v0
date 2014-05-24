S = require '../../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/tags'

  enableExternalProviders: off  # don't want uservoice + ga on admin

  routes:
    'list'        : 'list'

  appConstructor: (pageData, callback) ->
    d =
      tags: new C.Tags()
    v =
      tagsView: new V.TagsView el: '#list', collection: d.tags
      #tagsInputView: new V.TagsInputView collection: d.tags, model: d.selectedTags

    @resetOrFetch d.tags, pageData.tags

    _.extend d, v

  initialize: (args) ->
    @navTo 'list'
