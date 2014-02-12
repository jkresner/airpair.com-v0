exports = {}
BB      = require './../../lib/BB'
Models  = require './Models'

class exports.Experts extends BB.FilteringCollection
  model: Models.Expert
  url: '/api/experts'
  comparator: (m) -> m.get 'name'


module.exports = exports
