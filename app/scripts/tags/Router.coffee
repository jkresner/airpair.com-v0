exports = {}
S = require('./../shared/Routers')
M = require './Models'
C = require './Collections'
V = require './Views'


module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/tags'

  appConstructor: (pageData, callback) ->
    d =
      selectedTags: new M.TagListModel()
      tags: new C.Tags()
    v =
      tagsView: new V.TagsView collection: d.tags
      tagsInputView: new V.TagsInputView collection: d.tags, model: d.selectedTags

    @resetOrFetch d.tags, pageData.tags

    _.extend d, v


# on jQuery ready, construct a router instance w data injected from the page
$ -> window.initRouterWithPageData Router