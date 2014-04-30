exports = {}
BB      = require './../../lib/BB'
Models  = require './Models'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: '/api/orders/me'
  comparator: (m) ->
    -1 * moment(m.get('utc')).unix()

module.exports = exports
