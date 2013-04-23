exports = {}
BB = require './../../lib/BB'
Models = require './Models'
Shared = require './../shared/Collections'


exports.Tags = Shared.Tags


class exports.Requests extends BB.FilteringCollection
  model: Models.Request
  url: '/api/admin/requests'
  comparator: (m) -> m.get('events')[0].utc


module.exports = exports