exports = {}
BB      = require 'BB'
Models  = require './Models'


class exports.Tags extends BB.FilteringCollection
  model: Models.Tag
  url: '/api/tags'
  comparator: (m) -> m.get 'name'


class exports.Requests extends BB.FilteringCollection
  model: Models.Request
  url: '/api/requests'
  comparator: (m) -> m.createdDate()


class exports.MarketingTags extends BB.FilteringCollection
  model: Models.MarketingTag
  url: '/api/marketingtags'
  comparator: (m) -> m.get 'name'


module.exports = exports
