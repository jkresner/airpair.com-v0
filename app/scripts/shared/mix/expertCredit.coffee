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
expertCredit = (orders, expertId) ->
  orders = _.filter orders, (o) -> o.paymentStatus != 'pending'
  lisForExpert = getLineItemsForExpert orders, expertId
  byType = getBalanceByType groupExpertLineItemsByType lisForExpert
  total = calcTotal lisForExpert
  redeemed = calcRedeemed lisForExpert
  balance = total - redeemed

  { total, redeemed, balance, byType }

calcTotal = (lineItems) ->
  sum _.pluck lineItems || [], 'qty'

calcRedeemed = (lineItems) ->
  redeemedCalls = _.flatten _.pluck lineItems, 'redeemedCalls'
  redeemed = sum _.pluck redeemedCalls, 'qtyRedeemed'

getBalanceByType = (liByType) ->
  balanceByType = {}
  for type, lineItems of liByType
    total = calcTotal lineItems
    qtyRedeemed = calcRedeemed lineItems
    balance = total - qtyRedeemed
    balanceByType[type] = { total, qtyRedeemed, balance, type }
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


module.exports = expertCredit
_.extend module.exports, {
  getBalanceByType, groupExpertLineItemsByType, getLineItemsForExpert
}
