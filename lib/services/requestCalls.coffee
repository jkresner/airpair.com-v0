async = require 'async'
calendar = require './calendar'
videos = require './videos'
expertCredit = require '../../app/scripts/shared/mix/expertCredit'
sum = require '../../app/scripts/shared/mix/sum'
{ObjectId} = require('mongoose').Types

DomainService = require './_svc'
OrdersSvc = new (require('./orders'))()

Order = new require '../models/order'
Request = new require '../models/request'

module.exports = class RequestCallsService extends DomainService

  model: require './../models/request'

  getByCallPermalink: (permalink, callback) =>
    # find by permalink
    # check SEO completed & AirPair Authorized
    throw new Error 'not imp'

  getByExpertId: (expertId, callback) => throw new Error 'not imp'

  _canScheduleCall: (orders, call) =>
    credit = expertCredit orders, call.expertId
    byType = credit.byType[call.type]
    if !byType then return false
    call.duration <= byType.balance

  _qtyRemaining: (lineItem) ->
    lineItem.qty - sum _.pluck lineItem.redeemedCalls, 'qtyRedeemed'

  _modifyOrdersWithCallDuration: (orders, call) =>
    allocatedSoFar = 0
    done = false
    modified = []
    for order in orders
      if done then break
      order.lineItems.filter (lineItem) =>
        sameType = lineItem.type == call.type
        sameExpert = _.idsEqual lineItem.suggestion.expert._id, call.expertId
        sameType && sameExpert
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

  _byUtc: (order1, order2) ->
    order1.utc - order2.utc

  create: (userId, requestId, call, callback) =>
    call.status = 'pending'

    # change oldest orders first
    OrdersSvc.getByRequestId requestId, (err, orders) =>
      orders = orders.sort(@_byUtc)

      if err then return callback err
      Request.findOne({ _id: requestId }).exec (err, request) =>
        if err then return callback err

        if !@_canScheduleCall orders, call
          message = 'Not enough hours: buy more or cancel unfulfilled calls.'
          return callback new Error message

        # this lets us to update request & orders in parallel
        call._id = new ObjectId()

        # we make the gcal event first, because we need to put the event info
        # into the call object, and it is fiddly to get out the correct call
        # after it's been inserted into the calls array.
        calendar.create request.toJSON(), call, (err, eventData) =>
          if err then return callback err
          call.gcal = eventData

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

  update: (userId, requestId, call, callback) =>
    # TODO use async.waterfall to simplify this
    @getById requestId, (err, request) =>
      oldCall = _.find request.calls, (c) -> _.idsEqual c._id, call._id
      if !oldCall then return callback new Error('no such call ' + call._id)

      # TODO only get data for ones that have changed
      videos.list call.recordings, (err, recordings) =>
        # TODO: show error in UI when this happens
        if err then return callback err # might not have permissions, etc

        # TODO when we use waterfall, only push this function onto the list
        # if the dates are different.
        calendar.patch oldCall, call, (err, eventData) =>
          oldCall.gcal = eventData
          oldCall.recordings = recordings
          oldCall.notes = call.notes
          oldCall.datetime = call.datetime

          ups = { calls: request.calls }
          console.log 'update.ups = ', require('util').inspect(ups, depth: null)
          super requestId, ups, (err, newRequest) =>
            if err then return callback err
            newCall = _.find newRequest.calls, (c) -> _.idsEqual c._id, call._id
            callback null, newCall

  ###
  Takes a list of orders and a call, removes all redeemedCalls from the orders
  that match the call's ID

  Once you've unscheduled, you can _canScheduleCall and
  _modifyOrdersWithCallDuration as though it were a totally new call.

  TODO: _unschedule will lose the qtyCompleted count on the redeemedCalls, bad.
  ###
  # _unschedule: (orders, call) ->
  #   orders.map (o) ->
  #     o.lineItems = o.lineItems.map (li) ->
  #       li.redeemedCalls = li.redeemedCalls.filter (rc) ->
  #         rc.callId == call._id
  #       li
  #     o

  ###
  TODO: what does it mean to change the type? we unschedule and then reschedule,
  checking that there are hours available for that type.
  what does it mean to change the status?
    pending to completed
      update qtyCompleted on all redeemedCalls matching call._id

    pending to declined # not this version

    completed to pending
      NOT ALLOWED SORRY?
      If we did allow it, it would be important to first change the status
      using all the details of the old call (because we need to roll-back
      qtyCompleted changes). only then update other properties like duration.

  ChangedPropertyName: resource affected

  type:       change request,                    change orders
  duration:   change request, change gcal event, change orders
  status:     change request,                    change orders
  datetime:   change request, change gcal event,
  recordings: change request,                    change orders w/ qtyCompleted?
  notes:      change request,

  Updates are done this way to minimize async nesting & for efficiency
    - determine changed fields
    - for each changed field
      - fetch affected resource(s) if not already fetched
    - with each resource
      - make changes for each field
    - save all resources
  ###
  # update: (userId, requestId, call, callback) =>

  #   Request.findOne({ _id: requestId }).exec (err, request) =>
  #     if err then return callback err
  #     oldCall = _.find request.calls, _id: call._id

  ###
      # affectsOrders = [ 'type', 'duration', 'status', 'recordings' ]

      # changedProperties = diff(oldCall, call)
      # if !_.keys(changedProperties).length then return new Error 'no changes!'
      # tasks = {}
      # gcal = undefined
      # for prop in changedProperties
      #   if prop in affectsOrders
      #     tasks.orders = fetchOrders
      #   if prop in affectsGcal
      #     gcal = call.gcal
      # if _.keys tasks
      #   return async.parallel(tasks, onResources)
      # return makeUpdates()

      # onResources = (err, results) ->
      #   if err then return callback err
      #   makeUpdates(results.orders)

      # makeUpdates = (oldOrders) ->
      #   for prop in changedProperties
      #     update[prop]()

      #   update = {
      #     type:       -> oldCall.type = call.type; updateOrders() # unschedule, reschedule
      #     duration:   -> oldCall.duration = call.duration; updateOrders() # unschedule, reschedule
      #     status:     -> oldCall.status = call.status; updateOrders() # update qtyCompleted or qtyRedeemed depending on status change. ugh.
      #     datetime:   -> oldCall.datetime = call.datetime; updateGcal()
      #     recordings: -> oldCall.recordings = call.recordings; updateOrders() # update qtyCompleted? not in this version.
      #     notes:      -> oldCall.notes = call.notes
      #   }

      #   if gcal # make the gcal event changes before saving the request
      #     return updateGcal(gcal, saveToMongo)
      #   return saveToMongo()

      # saveToMongo (err, gcal) ->
      #   if gcal # it will be saved by saveRequest
      #     oldCall.gcal = gcal

      #   tasks = []
      #   if oldOrders then tasks.orders = saveOrders
      #   tasks.push(saveRequest)
      #   async.parallel tasks, (err, results) ->
      #     if err then return callback err

      # saveRequest = (cb) -> Request.save(request, cb)
      # saveOrders = (cb) -> async.forEach(saveOrder, cb)
      # saveOrder = (order, i, list, cb) -> Order.save(order, cb)
      ###

  # newEvent: DomainService.newEvent.bind(this)
