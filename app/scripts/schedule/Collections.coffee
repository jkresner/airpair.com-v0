exports = {}
BB = require './../../lib/BB'
Models = require './Models'
Shared = require './../shared/Collections'

class exports.Orders extends BB.FilteringCollection
  model: Models.Order
  url: -> "/api/orders/request/#{@requestId}"

exports.Requests = Shared.Requests

module.exports = exports
