async = require 'async'

Order = new require '../models/order'
Request = new require '../models/request'

sum = require '../../app/scripts/shared/mix/sum'
expertAvailability = require '../../app/scripts/shared/mix/expertAvailability'

{owner2name} = require '../identity/roles'
gcalCreate = require '../gcal/create'
ONE_HOUR = 3600000 # milliseconds

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
    call.status = 'pending'

    # change oldest orders first
    Order.find({ requestId }).sort('utc').exec (err, orders) =>
      if err then return callback err
      Request.findOne({ _id: requestId }).exec (err, request) =>
        if err then return callback err

        if !@_canScheduleCall orders, call
          message = 'Not enough hours: buy more or cancel unfulfilled calls.'
          return callback new Error message

        # this lets us to update request & orders in parallel
        call._id = new ObjectId()

        # TODO sorry, but here I'm going to make the gcal event first, because we
        # need to put the event info into the call object, and it is fiddly to get
        # out the correct call after it's been inserted into the calls array.
        @_createCalendarEvent request, call, (err, eventData) =>
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

  update: (userId, data, callback) => throw new Error 'not imp'

  # newEvent: DomainService.newEvent.bind(this)

  owner2color:
    mi: undefined # default color for the calendar, #9A9CFF
    '': 1  # blue
    il: 2  # green
    '': 3  # purple
    '': 4  # red
    '': 5  # yellow
    jk: 6  # orange = jk
    '': 7  # turqoise
    '': 8  # gray
    '': 9  # bold blue
    dt: 10 # bold green
    pl: 11 # bold red = pl

  _createCalendarEvent: (request, call, cb) =>
    start = call.datetime
    owner = request.owner
    sug = (_.find request.suggested, (s) -> s.expert._id == call.expertId)
    expert = sug.expert
    ename = expert.name.replace /\s.*/g, ''
    cname = request.company.contacts[0].fullName.replace /\s.*/g, ''
    body =
      start:
        dateTime: start.toISOString()
      end:
        dateTime: @_addTime(start, call.duration * ONE_HOUR).toISOString()
      attendees: [
        email: "#{owner}@airpair.com"
        email: request.company.contacts[0].email
        email: sug.expert.email
      ]
      summary: "TEST Airpair (#{request.tags[0].name})"
      colorId: @owner2color[owner]
      description: "Your account manager, #{owner2name[owner]} will set up a" +
        "google hangout for this session and invite you to it."

    gcalCreate body, cb

  _addTime: (original, milliseconds) ->
    new Date original.getTime() + milliseconds
