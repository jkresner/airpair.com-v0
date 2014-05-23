idsEqual = require './idsEqual'
sum      = require './sum'

###
orders is a list of orders associated with a certain request
expertId is the Id of an expert who the customer has chosen

This supports two use-cases:
  - how much time can an expert be booked when you sum all their hours across
    orders
  - how much time can an expert be booked given this only one order in the array
###
calcExpertCredit = (orders, expertId) ->
  orders = _.filter orders, (o) -> o.paymentStatus != 'pending'
  lisForExpert = getLineItemsForExpert orders, expertId
  byType = getBalanceByType groupExpertLineItemsByType lisForExpert
  total = calcTotal lisForExpert
  redeemed = calcRedeemed lisForExpert
  balance = total - redeemed
  completed = calcCompleted lisForExpert

  { total, redeemed, balance, completed, byType }

calcTotal = (lineItems) ->
  sum _.pluck lineItems || [], 'qty'

getRedeemedCalls = (lineItems) ->
  _.flatten _.pluck lineItems, 'redeemedCalls'

calcRedeemed = (lineItems) ->
  redeemedCalls = getRedeemedCalls(lineItems)
  redeemed = sum _.pluck redeemedCalls, 'qtyRedeemed'

calcCompleted = (lineItems) =>
  redeemedCalls = getRedeemedCalls(lineItems)
  sum _.pluck redeemedCalls, 'qtyCompleted'

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


module.exports = calcExpertCredit
_.extend module.exports, {
  getBalanceByType, groupExpertLineItemsByType, getLineItemsForExpert,
  calcTotal, calcRedeemed, calcCompleted
}
