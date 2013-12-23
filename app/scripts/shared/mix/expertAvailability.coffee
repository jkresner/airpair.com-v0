idsEqual = require './idsEqual'
sum = require './sum'

###
orders is a list of orders associated with a certain request
expertId is the Id of an expert who the customer has chosen

This supports two use-cases:
  - how much time can an expert be booked when you sum all their hours across
    orders
  - how much time can an expert be booked given this only one order in the array
###
expertAvailability = (orders, expertId) ->
  lisForExpert = getLineItemsForExpert orders, expertId
  byType = getBalanceByType groupExpertLineItemsByType(lisForExpert)
  total = sum _.pluck lisForExpert || [], 'qty'
  redeemedCalls = _.flatten _.pluck lisForExpert, 'redeemedCalls'
  redeemed = sum _.pluck redeemedCalls, 'qtyRedeemed'
  balance = total - redeemed

  { total, redeemed, balance, byType }


getBalanceByType = (liByType) ->
  balanceByType = {}
  for type, lineItems of liByType
    total = 0
    qtyRedeemed = 0
    for li in lineItems
      total += li.qty
      qtyRedeemed += li.qtyRedeemed
    balance = total - qtyRedeemed
    balanceByType[type] = {total,qtyRedeemed,balance,type}
  balanceByType


groupExpertLineItemsByType = (expertLineItems) ->
  liByType = {}
  for li in expertLineItems
    if liByType[li.type]?
      liByType[li.type].push li
    else
      liByType[li.type] = [ li ]
  liByType


getLineItemsForExpert = (orders, expertId) ->
  lineItems = []
  for o in orders
    for li in o.lineItems
      lineItems.push li if idsEqual li.suggestion.expert._id, expertId
  lineItems


module.exports = expertAvailability
_.extend module.exports, {
  getBalanceByType, groupExpertLineItemsByType, getLineItemsForExpert
}
