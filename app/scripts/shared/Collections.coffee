exports = {}
BB      = require 'BB'
Models  = require './Models'


_.extend exports, require './../tags/Collections'
_.extend exports, require './../marketingtags/Collections'


class exports.Requests extends BB.FilteringCollection
  model: Models.Request
  url: '/api/requests'
  comparator: (m) -> m.createdDate()



module.exports = exports
