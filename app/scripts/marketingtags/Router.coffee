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
    v =
      marketingTagList: new V.MarketingTagList
        selected: d.marketingTag, collection: d.marketingTags
      marketingTagForm: new V.MarketingTagForm
        model: d.marketingTag, collection: d.marketingTags

    @resetOrFetch d.marketingTags, pageData.marketingTags

    _.extend d, v

  initialize: (args) ->
