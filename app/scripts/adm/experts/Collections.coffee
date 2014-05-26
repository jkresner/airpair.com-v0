exports = {}
BB      = require 'BB'
Models  = require './Models'
Shared  = require '../../shared/Collections'

exports.Tags = Shared.Tags

class exports.Experts extends BB.FilteringCollection
  model: Models.Expert
  url: '/api/experts'
  comparator: (m) -> m.get 'name'


module.exports = exports
