idsEqual = require './idsEqual'
sum = require './sum'

module.exports =
expertAvailability = (orders, expertId) ->
  expertTotal = 0
  expertRedeemed = 0

  _.map orders, (order) ->
    expertLineItems = _.filter order.lineItems, (lineItem) ->
      idsEqual lineItem.suggestion.expert._id, expertId
    _.map expertLineItems, (lineItem) ->
      expertRedeemed += sum _.pluck lineItem.redeemedCalls || [], 'qtyRedeemed'
      expertTotal += lineItem.qty

  { expertTotal, expertRedeemed, expertBalance: expertTotal - expertRedeemed }
