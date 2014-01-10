exports = {}
BB = require './../../lib/BB'
M = require './Models'

class exports.MarketingTags extends BB.FilteringCollection
  model: M.MarketingTag
  url: '/api/marketingtags'
  comparator: (m) -> m.get 'name'

module.exports = exports
