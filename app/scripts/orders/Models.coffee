BB = require './../../lib/BB'
Shared = require './../shared/Models'
exports = {}


exports.Order = class Order extends Shared.Order

  successfulPayoutIds: =>
    @get('payouts').filter (p) ->
      p.status == 'success'
    .map (p) ->
      p.lineItemId

module.exports = exports
