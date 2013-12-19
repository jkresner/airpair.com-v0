# DomainService  = require './_svc'

Order = new require 'lib/models/order'
Request = new require 'lib/models/request'

module.exports = class RequestCallsService

  model: require './../models/request'

  getByCallPermalink: (permalink, callback) =>
    # find by permalink
    # check SEO completed & AirPair Authorized
    throw new Error 'not imp'

  getByExpertId: (expertId, callback) => throw new Error 'not imp'

  _canScheduleCall: (orders, call) =>
    expertTotal = 0
    expertRedeemed = 0
    orders.map (order) =>
      order.lineItems.filter (lineItem) =>
        _.idsEqual lineItem.suggestion.expert._id, call.expertId
      .map (lineItem) =>
        expertRedeemed += @sum _.pluck lineItem.redeemedCalls, 'qtyRedeemed'
        expertTotal += lineItem.qty

    expertBalance = expertTotal - expertRedeemed

    call.duration <= expertBalance

  create: (userId, requestId, call, callback) =>

    # TODO make this a client-side require-able function

    Order.find { requestId }, (err, orders) =>
      if err then return callback err

      if !@_canScheduleCall orders, call
        message = 'Not enough hours: buy more or cancel unfulfilled calls.'
        return callback new Error message

      # TODO update order
      Request.findByIdAndUpdate requestId, $push: calls: call, callback

  sum: (list) ->
    add = (prev, cur) ->
      prev + cur
    list.reduce add, 0

  expertReply: (userId, data, callback) =>
    { callId, status } = data # stats (accept / decline)
    # expert = something.userId
    # adjust the order qtyRedeemedCallIds

  customerFeedback: (userId, data, callback) =>
    # adjust the order qtyRedeemedCallIds

  expertFeedback: (userId, data, callback) =>
    # adjust the order qtyRedeemedCallIds

  updateCms: (userId, data, callback) =>


  update: (userId, data, callback) => throw new Error 'not imp'

  # newEvent: DomainService.newEvent.bind(this)
