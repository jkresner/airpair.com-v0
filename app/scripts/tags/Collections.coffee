exports = {}
BB = require './../../lib/BB'
Models = require './Models'

class exports.Tags extends BB.PagingCollection
  model: Models.Tag
  url: '/api/tags'
  comparator: (m) -> m.get 'name'


module.exports = exports