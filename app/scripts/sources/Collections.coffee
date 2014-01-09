exports = {}
BB = require './../../lib/BB'
M = require './Models'

class exports.Sources extends BB.FilteringCollection
  model: M.Source
  url: '/api/sources'
  comparator: (m) -> m.get 'name'

module.exports = exports
