async      = require 'async'
calendar   = require './calendar'
videos     = require './videos'
mailman    = require '../mail/mailman'
roles      = require '../identity/roles'
{ObjectId} = require('mongoose').Types

OrdersSvc  = new (require('./orders'))()
RequestSvc = new (require './requests')()

Order   = new require '../models/order'
Request = new require '../models/request'

module.exports = class RequestCallsService

  model: require './../models/request'
  calendar: calendar
  mailman: mailman

  getByCallPermalink: (permalink, callback) =>
    # find by permalink
    # check SEO completed & AirPair Authorized
    throw new Error 'not imp'

  getByExpertId: (expertId, callback) =>
    query = 'calls.expertId': expertId
    select = 'calls.notes': 0
    Request.find(query, select).lean().exec (err, requests) =>
      if err then return callback err
      calls = _.flatten requests.map (r) ->
        r.calls.filter((c) -> _.idsEqual c.expertId, expertId)
          .map (c) ->
            c.company = r.company
            c.userId = r.userId
            c

      callback null, calls

  create: (user, requestId, call, callback) =>
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

      # dont make gcal right away for customers
      if true || !roles.isAdmin(user) then return saveCallToRequest(orders)

      # we make the gcal event first, because we need to put the event info
      # into the call object, and it is fiddly to get out the correct call
      # after it's been inserted into the calls array.
      @calendar.create request, call, (err, eventData) =>
        if err then return callback err
        call.gcal = eventData
        saveCallToRequest(orders)

    saveCallToRequest = (orders) =>
      ups = $push: calls: call
      Request.findByIdAndUpdate requestId, ups, (err, modifiedRequest) =>
        callback null, { request: modifiedRequest, orders: orders }

  rsvp: (expert, callId, status, callback) =>
    console.log '0'
    query = calls: $elemMatch:
      '_id': callId
      'expertId': expert._id
      'status': 'pending'
    select = 'events': 0
    Request.findOne(query, select).lean().exec (err, request) =>
      console.log '1'
      if !request then return callback()
      console.log '2'

      call = _.find request.calls, (c) -> _.idsEqual c._id, callId

      # if call.gcal then return callback() # TODO legacy admin calls no touchy!

      call.status = status
      console.log 'ey', call.status
      if call.status == 'confirmed' then return confirmed(request, call)
      if call.status == 'declined' then return declined(request, call)
      return callback new Error 'rsvp: this should never happen'

    # create gcal
    confirmed = (request, call) =>
      console.log '3c'
      call.sendNotifications = true
      @calendar.create request, call, (err, eventData) =>
        if err then return callback err
        call.gcal = eventData
        updateCall null, request, call

    # email customer saying the expert said no
    declined = (request, call) =>
      console.log '3d'
      @mailman.callDeclined expert, request, call, (err) =>
        updateCall(err, request, call)

    updateCall = (err, request, call) =>
      console.log '4'
      if err then return callback err
      query =
        _id: request._id
        calls: $elemMatch: _id: callId
      ups = 'calls.$': call
      Request.findOneAndUpdate(query, ups).lean().exec callback

  customerFeedback: (userId, data, callback) =>
    # adjust the order qtyRedeemedCallIds

  expertFeedback: (userId, data, callback) =>
    # adjust the order qtyRedeemedCallIds

  updateCms: (userId, data, callback) =>

  update: (userId, requestId, call, callback) =>
    RequestSvc.getById(requestId).lean().exec (err, request) =>
      oldCall = _.find request.calls, (c) -> _.idsEqual c._id, call._id
      if !oldCall then return callback new Error('no such call ' + call._id)

      oldCall.recordings = call.recordings
      @_updateOrders requestId, oldCall, call.duration, (err) =>
        if err then return callback err

        # pass in both old & new: it decides whether updates are truly needed
        @calendar.patch oldCall, call, (err, eventData) =>
          if err then return callback err
          oldCall.gcal = eventData
          oldCall.notes = call.notes
          oldCall.datetime = call.datetime
          oldCall.duration = call.duration

          ups = { calls: request.calls }
          RequestSvc.update requestId, ups, (err, newRequest) =>
            if err then return callback err
            newCall = _.find newRequest.calls, (c) -> _.idsEqual c._id, call._id
            callback null, newCall

  _updateOrders: (requestId, oldCall, newDuration, callback) =>
    if oldCall.duration == newDuration
      console.log 'duration unchanged'
      return OrdersSvc.updateCompletion requestId, oldCall, callback

    callWithNewDuration = _.clone oldCall
    callWithNewDuration.duration = newDuration
    OrdersSvc.updateWithCall requestId, callWithNewDuration, callback

  delete: (requestId, callId, callback) =>
    query =
      '_id': requestId
      calls: $elemMatch: _id: callId
    ups = $pull: calls: _id: new ObjectId callId
    Request.findOneAndUpdate(query, ups).lean().exec (err, request) =>
      if err then return callback err
      callback null, {}
