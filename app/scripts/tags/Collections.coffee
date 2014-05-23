exports = {}
BB      = require 'BB'
Models  = require './Models'

class exports.Tags extends BB.FilteringCollection
  model: Models.Tag
  url: '/api/tags'
  comparator: (m) -> m.get 'name'


module.exports = exports
