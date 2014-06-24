async      = require 'async'
calendar   = require './calendar'
videos     = require './videos'
{ObjectId} = require('mongoose').Types

OrdersSvc  = new (require('./orders'))()
RequestSvc = new require './requests'

Order   = new require '../models/order'
Request = new require '../models/request'

module.exports = class RequestCallsService

  model: require './../models/request'
  calendar: calendar

  getByCallPermalink: (permalink, callback) =>
    # find by permalink
    # check SEO completed & AirPair Authorized
    throw new Error 'not imp'

  getByExpertId: (expertId, callback) => throw new Error 'not imp'

  create: (userId, requestId, call, callback) =>
    call.status = 'pending'
    # this lets us to update orders before inserting the call into Mongo
    call._id = new ObjectId()
    tasks =
      orders: (cb) ->
        OrdersSvc.schedule requestId, call, cb
      request: (cb) ->
        Request.findOne({ _id: requestId }).lean().exec cb

    async.parallel tasks, (err, results) =>
      if err then return callback err
      {orders, request} = results

      # we make the gcal event first, because we need to put the event info
      # into the call object, and it is fiddly to get out the correct call
      # after it's been inserted into the calls array.
      @calendar.create request, call, (err, eventData) =>
        if err then return callback err
        call.gcal = eventData

        ups = $push: calls: call
        Request.findByIdAndUpdate requestId, ups, (err, modifiedRequest) =>
          callback null, { request: modifiedRequest, orders: orders }

  # expertReply: (data, callback) =>
  #   { callId, status } = data # stats (accept / decline)
  #   # expert = something.userId
  #   # adjust the order qtyRedeemedCallIds

  # customerFeedback: (data, callback) =>
  #   # adjust the order qtyRedeemedCallIds

  # expertFeedback: (data, callback) =>
  #   # adjust the order qtyRedeemedCallIds

  # updateCms: (data, callback) =>

  # TODO this is going to look way different once we start completing calls
  # when they have a youtube video. We'll be passing old & new orders around.
  update: (requestId, call, callback) =>
    rSvc = new RequestSvc @usr
    # $log 'rCall', 'r', requestId, call
    rSvc.getById requestId, (err, request) =>
      oldCall = _.find request.calls, (c) -> _.idsEqual c._id, call._id
      if !oldCall then return callback new Error('no such call ' + call._id)

      oldCall.recordings = call.recordings
      @_updateOrders requestId, oldCall, call.duration, (err) =>
        if err then return callback err

        $log 'rCall', 'update', request._id
        # pass in both old & new: it decides whether updates are truly needed
        @calendar.patch oldCall, call, (err, eventData) =>
          if err then return callback err
          oldCall.gcal = eventData
          oldCall.notes = call.notes
          oldCall.datetime = call.datetime
          oldCall.duration = call.duration

          ups = { calls: request.calls }
          rSvc.update requestId, ups, (err, newRequest) =>
            if err then return callback err
            newCall = _.find newRequest.calls, (c) -> _.idsEqual c._id, call._id
            callback null, newCall

  _updateOrders: (requestId, oldCall, newDuration, callback) =>
    if oldCall.duration == newDuration
      return OrdersSvc.updateCompletion requestId, oldCall, callback

    callWithNewDuration = _.clone oldCall
    callWithNewDuration.duration = newDuration
    OrdersSvc.updateWithCall requestId, callWithNewDuration, callback
