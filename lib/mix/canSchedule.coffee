calcExpertCredit = require './calcExpertCredit'

module.exports =
canSchedule = (orders, call) =>
  credit = calcExpertCredit orders, call.expertId
  byType = credit.byType[call.type]
  if !byType then return false
  call.duration <= byType.balance
