# DomainService  = require './_svc'

Order = new require 'lib/models/order'
Request = new require 'lib/models/request'
sum = require '../../app/scripts/shared/mix/sum'
expertAvailability = require '../../app/scripts/shared/mix/expertAvailability'
async = require 'async'
{ObjectId} = require('mongoose').Types

module.exports = class RequestCallsService

  model: require './../models/request'

  getByCallPermalink: (permalink, callback) =>
    # find by permalink
    # check SEO completed & AirPair Authorized
    throw new Error 'not imp'

  getByExpertId: (expertId, callback) => throw new Error 'not imp'

  # TODO make this a client-side require-able function
  _canScheduleCall: (orders, call) =>
    availability = expertAvailability orders, call.expertId
    call.duration <= availability.balance

  _qtyRemaining: (lineItem) ->
    lineItem.qty - sum _.pluck lineItem.redeemedCalls, 'qtyRedeemed'

  # TODO another function to reduce the duration of a call / subtracting hours from orders
  _modifyOrdersWithCallDuration: (orders, call) =>
    allocatedSoFar = 0
    done = false
    modified = []
    for order in orders
      if done then break
      order.lineItems.filter (lineItem) =>
        _.idsEqual lineItem.suggestion.expert._id, call.expertId
      .map (lineItem) =>
        if done then return
        redeemedCall = { callId: call._id, qtyRedeemed: 0, qtyCompleted: 0 }
        lineItem.redeemedCalls = lineItem.redeemedCalls || []
        allocated = Math.min call.duration, @_qtyRemaining(lineItem)
        allocatedSoFar += allocated
        redeemedCall.qtyRedeemed += allocated

        lineItem.redeemedCalls.push redeemedCall
        modified.push order
        order.markModified 'lineItems'
        done = allocatedSoFar == call.duration
    modified

  _saveOrdersWithCallDuration: (orders, callback) =>
    saveOrder = (order, cb) ->
      update = $set: { lineItems: order.toJSON().lineItems }
      Order.findByIdAndUpdate order._id, update, cb
    async.map orders, saveOrder, callback

  create: (userId, requestId, call, callback) =>

    # change oldest orders first
    Order.find({ requestId }).sort('utc').exec (err, orders) =>
      if err then return callback err

      if !@_canScheduleCall orders, call
        message = 'Not enough hours: buy more or cancel unfulfilled calls.'
        return callback new Error message

      # this lets us to update request & orders in parallel
      call._id = new ObjectId()

      modifiedOrders = @_modifyOrdersWithCallDuration orders, call
      tasks =
        request: (cb) => Request.findByIdAndUpdate requestId, $push: calls: call, cb
        orders: (cb) => @_saveOrdersWithCallDuration modifiedOrders, cb
      async.parallel tasks, callback

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
