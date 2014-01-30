exports = {}
BB      = require '../../lib/BB'
Models  = require './Models'
Shared  = require '../shared/Collections'
SM      = require '../shared/Models'

exports.Requests = Shared.Requests

class exports.Orders extends BB.FilteringCollection
  url: '/api/orders'
  model: SM.Order
  comparator: (m) ->
    -1 * moment(m.get('utc')).unix()

module.exports = exports
