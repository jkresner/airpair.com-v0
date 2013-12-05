exports = {}
BB = require './../../lib/BB'
Models = require './Models'
# <<<<<<< Updated upstream

# class exports.Orders extends BB.FilteringCollection
#   model: Models.Order
#   url: -> "/api/orders/request/#{@requestId}"

#   ->
#     # paymentStatus == "paid"
#     # qtyRedeemedCallIds.length < qty

#     # return orders

#     # merge the experts from orders into ?unique array

#     [
#       experdAId : { expertA, qtyAvaiable }
#       experdBId : { expertB, qtyAvaiable }
#       experdCId : { expertC, qtyAvaiable }
#     ]

#     ###
#     bookable = []
#     for order in orders if paymentStatus == 'paid'
#       for li in order.lineItems
#         remainingHrs = li.qty - li.qtyRedeemedCallIds.length
#         if remainingHrs > 0
#           if bookable.experId? then bookable.experId.qtyAvailable += remainingHrs
#           else bookable[experId] = { expert: li.expert, qtyAvailable: remianinHrs }

#     bookable

#     ###
# =======
Shared = require './../shared/Collections'

exports.Requests = Shared.Requests

module.exports = exports
