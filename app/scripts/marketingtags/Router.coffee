S = require '../shared/Routers'
M = require './Models'
C = require './Collections'
V = require './Views'

module.exports = class Router extends S.AirpairSessionRouter

  pushStateRoot: '/adm/marketingtags'
  enableExternalProviders: off
  appConstructor: (pageData, callback) ->
    d =
      marketingTag: new M.MarketingTag()
      marketingTags: new C.MarketingTags()
      selected: new M.MarketingTag()
    v =
      marketingTagList: new V.MarketingTagList
        collection: d.marketingTags, selected: d.selected
      marketingTagForm: new V.MarketingTagForm
        model: d.marketingTag, selected: d.selected, collection: d.marketingTags
      marketingTagEditForm: new V.MarketingTagEditForm
        model: d.selected, collection: d.marketingTags

    @resetOrFetch d.marketingTags, pageData.marketingTags

    _.extend d, v

  initialize: (args) ->
