BB      = require 'BB'
Shared  = require './../shared/Models'
exports = {}


exports.Order = class Order extends Shared.Order

  successfulPayoutIds: =>
    @get('payouts').filter (p) ->
      p.status == 'success'
    .map (p) ->
      p.lineItemId

  isLineItemPaidOut: (li) =>
    _.contains @successfulPayoutIds(), li._id

module.exports = exports
