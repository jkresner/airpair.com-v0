exports = {}
BB = require './../../lib/BB'
Models = require './Models'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: -> "/api/orders/request/#{@requestId}"


module.exports = exports
