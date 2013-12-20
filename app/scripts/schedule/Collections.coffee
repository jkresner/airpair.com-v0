exports = {}
BB = require './../../lib/BB'
Models = require './Models'

class exports.Orders extends BB.FilteringCollection
  logging: on
  model: Models.Order
  url: -> "/api/orders/request/#{@requestId}"

Shared = require './../shared/Collections'
exports.Requests = Shared.Requests

module.exports = exports
