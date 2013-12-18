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

  create: (userId, requestId, call, callback) =>
    expertTotal = 0
    callIdSet = []
    Order.find { requestId }, (err, orders) =>
      if err then return callback err
      orders.map (order) ->
        order.lineItems.filter (lineItem) ->
          _.idsEqual lineItem.suggestion.expert._id, call.expertId
        .map (lineItem) ->
          expertTotal += lineItem.qty
          callIdSet = callIdSet.concat lineItem.qtyRedeemedCallIds

      Request.find { 'calls._id': '$in': callIdSet }, (err, requests) =>
        if err then return callback err
        calls = _.pluck(requests, 'calls')
        calls = _.flatten(calls)
        durations = _.pluck(calls, 'duration')
        redeemedDuration = @sum durations

        expertBalance = expertTotal - redeemedDuration

        if expertBalance + call.duration > expertTotal
          message = 'Not enough hours: buy more or cancel unfulfilled calls.'
          callback new Error message

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
