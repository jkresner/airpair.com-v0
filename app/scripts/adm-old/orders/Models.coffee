BB      = require 'BB'
Shared  = require '../../shared/Models'
exports = {}


exports.Request = Shared.Request

exports.Order = class Order extends Shared.Order

  successfulPayoutIds: =>
    ids = []
    payouts = if @get('payouts')? then @get('payouts') else []
    for p in payouts
      ids.push p.lineItemId if p.status == 'success'
    ids

  isLineItemPaidOut: (li) =>
    _.contains @successfulPayoutIds(), li._id


module.exports = exports
