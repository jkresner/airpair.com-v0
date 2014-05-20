{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require '../test-lib-setup'
{app, data} = require '../test-app-setup'

async     = require 'async'
cloneDeep = require 'lodash.clonedeep'
moment    = require 'moment'
ObjectId  = require('mongoose').Types.ObjectId

unschedule       = require '../../../app/scripts/shared/mix/unschedule'
calcExpertCredit = require '../../../app/scripts/shared/mix/calcExpertCredit'
ordersSvc        = new (require '../../../lib/services/orders')()
requestsSvc      = new (require '../../../lib/services/requests')(data.users[13])
viewDataSvc      = new (require '../../../lib/services/_viewdata')()
svc              = new (require '../../../lib/services/requestCalls')()

describe "RequestCallsService", ->
  @testNum = 0
  user = data.users[13]  # bchristie
  request = data.requests[10] # experts[0] = paul, experts[1] = matthews
  request = _.omit request, '_id'
  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach () ->
    @testNum++

  saveOrdersForRequest = (orders, request, callback) ->
    createOrder = (order, cb) ->
      order = _.omit order, '_id'
      order.requestId = request._id
      ordersSvc.create order, user, (err, newOrder) ->
        if err then return cb new Error(err.message)
        return cb null, newOrder
    async.map orders, createOrder, callback

  runCreateCallSuccess = (orders, call, callback) ->
    requestsSvc.create request, (err, newRequest) ->

      saveOrdersForRequest orders, newRequest, (err, __) ->

        # $log 'runCreateCallSuccess', call
        svc.create user._id, newRequest._id, call, (err, results) ->

          newRequestWithCall = results.request
          expect(newRequestWithCall).to.be.a 'object'
          expect(newRequestWithCall.calls.length).to.equal 1
          expect(newRequestWithCall.calls[0]).to.be.a 'object'
          newCall = newRequestWithCall.calls[0]
          expect(_.idsEqual newCall.expertId, request.suggested[0].expert._id)
            .to.be.true
          expect(newCall.type).to.equal request.pricing
          return callback null, results.orders, newRequestWithCall, newCall

  it "can book a 1hr call using 1 order and 1 available lineitem", (done) ->
    @timeout 10000
    call = data.calls[1] # expert is paul
    orders = [cloneDeep data.orders[5]] # expert is paul, 2 line items
    runCreateCallSuccess orders, call, (err, newOrders, __, ___) ->
      if err then return done err
      order = newOrders[0]
      redeemed = order.lineItems[0].redeemedCalls
      expect(redeemed).to.be.a 'array'
      expect(redeemed[0]).to.be.a 'object'
      expect(redeemed[0].qtyRedeemed).to.equal 1
      done()

  it "can book a 2hr call given 2 orders and 2 available lineItems", (done) ->
    @timeout 10000
    call = data.calls[2] # duration 2
    orders = [cloneDeep(data.orders[5]), cloneDeep(data.orders[5])]
    runCreateCallSuccess orders, call, done

  it "cannot book a 5hr call given 2 orders and 2 lineItems", (done) ->
    @timeout 10000
    call = _.clone data.calls[2]
    call.duration = 5
    orders = [cloneDeep(data.orders[5]), cloneDeep(data.orders[5])]
    requestsSvc.create request, (err, newRequest) ->
      if err then return done err
      saveOrdersForRequest orders, newRequest, (err, newOrders) ->
        if err then return done err
        svc.create user._id, newRequest._id, call, (err, newRequestWithCall) ->
          expect(err).to.exist
          expect(err.message).to.match /Not enough/i
          done()

  it "can book a 2h OSS session and then a 5 hour private session", (done) ->
    @timeout 10000
    callos2 = cloneDeep data.calls[3]
    callp5 = cloneDeep data.calls[4]
    request = cloneDeep data.requests[12]

    orders = [ cloneDeep(data.orders[6]), cloneDeep(data.orders[7]) ]
    requestsSvc.create request, (err, newRequest) =>
      if err then return done err

      saveOrdersForRequest orders, newRequest, (err, newOrders) =>
        if err then return done err
        svc.create user._id, newRequest._id, callos2, (err, results) =>
          if err then return done err
          modifiedRequest = results.request
          modifiedOrders = results.orders
          # it only changes one, but we expect it to change the OSS order
          expect(modifiedOrders.length).to.equal(1)
          expect(modifiedOrders[0].lineItems[0].type).to.equal 'opensource'
          expect(modifiedRequest.calls.length).to.equal 1
          expect(modifiedRequest.calls[0].duration).to.equal 2

          svc.create user._id, newRequest._id, callp5, (err, results) =>
            if err then return done err
            modifiedRequest = results.request
            modifiedOrders = results.orders
            # the previously saved call is still there
            expect(modifiedRequest.calls.length).to.equal 2
            expect(modifiedRequest.calls[0].duration).to.equal 2

            # the new call matches the 5 hour private one we just tried to save
            expect(modifiedOrders.length).to.equal 1
            expect(modifiedOrders[0].lineItems[0].type).to.equal 'private'
            expect(modifiedRequest.calls[1].duration).to.equal 5

            # for use in the next test
            @modifiedRequest = modifiedRequest
            done()

  getRedeemedCalls = (order) ->
    rcs = []
    for li in order.lineItems
      rcs.concat li.redeeemedCalls
    rcs

  hasCall = (callId, rcs) ->
    _.any rcs, (rc) -> _.idsEqual callId, rc.callId

  callInOrders = (callId, orders) ->
    rcs = _.flatten orders.map getRedeemedCalls
    hasCall(rcs, callId)

  getCall = (request, callId) ->
    _.find request.calls, (c) -> _.idsEqual c._id, callId

  # it 'edit 2h OSS & 5h private down to 1h then private back to 4h', (done) ->
  #   @timeout 10000
  #   callId1 = @modifiedRequest.calls[0]._id
  #   callId2 = @modifiedRequest.calls[1]._id

  #   # let's run thru it like we were a real client!
  #   # hit viewdata for the call and unscheduled orders
  #   viewDataSvc.callEdit null, callId1, (err, json) =>
  #     if err then return done err
  #     request = JSON.parse json.request
  #     call = getCall request, callId1
  #     orders = JSON.parse json.orders
  #     ordersWithoutCall = unschedule orders, call._id
  #     # assert that there are no redeemedCalls whose callIds match this call
  #     expect(callInOrders(callId1, ordersWithoutCall)).to.equal false
  #     credit = calcExpertCredit ordersWithoutCall, call.expertId
  #     expect(call.type).to.equal 'opensource'
  #     expect(credit.byType[call.type].balance).to.equal 2

  #     $log 'still going 1', json

  #     # change the duration to 1, and the time just for kicks, and also the note
  #     call.duration = 1
  #     hammerTime = new Date()
  #     call.datetime = hammerTime
  #     badassNotes = 'waddup im editing you for the first time ever'
  #     call.notes = badassNotes

  #     # dont let it make calls to google
  #     svc.calendar.google.patchEvent = (eventId, body, cb) ->
  #       cb null, _.extend call.gcal, body
  #     svc.update request.userId, request._id, call, (err, newCall) =>
  #       if err then return done err
  #       # assert gcal duration is changed using moment.diff
  #       # assert start time is different
  #       # assert note is the same
  #       expect(newCall.duration).to.equal 1
  #       expect(newCall.notes).to.equal badassNotes
  #       expect(newCall.datetime.getTime()).to.equal hammerTime.getTime()
  #       start = moment newCall.gcal.start.dateTime
  #       end = moment newCall.gcal.end.dateTime
  #       expect(end.diff(start, 'hours')).to.equal 1
  #       nextEdit()

  #   nextEdit = ->
  #     # hit viewdata for call2
  #     viewDataSvc.callEdit null, callId2, (err, json) =>
  #       if err then return done err
  #       request = JSON.parse json.request
  #       call = getCall request, callId2
  #       orders = JSON.parse json.orders
  #       ordersWithoutCall = unschedule orders, call._id
  #       # assert call2 is not in the orders
  #       expect(callInOrders(callId2, ordersWithoutCall)).to.equal false
  #       credit = calcExpertCredit ordersWithoutCall, call.expertId
  #       # assert that the OSS credit is 1hr
  #       expect(credit.byType['opensource'].balance).to.equal 1
  #       # assert that the private credit is 5hr
  #       expect(call.type).to.equal 'private'
  #       expect(credit.byType[call.type].balance).to.equal 5

  #       # change duration to 1, and the time just for kicks, and also the note
  #       call.duration = 1
  #       hammerTime = new Date()
  #       call.datetime = hammerTime
  #       badassNotes = 'waddup this is the second time ive ever edited a call'
  #       call.notes = badassNotes
  #       svc.update request.userId, request._id, call, (err, newCall) =>
  #         if err then return done err
  #         # assert gcal duration is changed using moment.diff
  #         # assert start time is different
  #         # assert note is the same
  #         expect(newCall.duration).to.equal 1
  #         expect(newCall.notes).to.equal badassNotes
  #         expect(newCall.datetime.getTime()).to.equal hammerTime.getTime()
  #         start = moment newCall.gcal.start.dateTime
  #         end = moment newCall.gcal.end.dateTime
  #         expect(end.diff(start, 'hours')).to.equal 1
  #         lastEdit()

  #   lastEdit = ->
  #     # switch the private call to duration 4
  #     viewDataSvc.callEdit null, callId2, (err, json) =>
  #       if err then return done err
  #       request = JSON.parse json.request
  #       call = getCall request, callId2
  #       orders = JSON.parse json.orders
  #       ordersWithoutCall = unschedule orders, call._id
  #       # assert call2 is not in the orders
  #       expect(callInOrders(callId2, ordersWithoutCall)).to.equal false
  #       credit = calcExpertCredit ordersWithoutCall, call.expertId
  #       # assert that the OSS credit is 1hr
  #       expect(credit.byType['opensource'].balance).to.equal 1
  #       # assert that the private credit is 5hr
  #       expect(call.type).to.equal 'private'
  #       expect(credit.byType[call.type].balance).to.equal 5

  #       call.datetime = new Date()
  #       call.duration = 4
  #       svc.update request.userId, request._id, call, (err, newCall) =>
  #         if err then return done err
  #         expect(newCall.duration).to.equal 4
  #         start = moment newCall.gcal.start.dateTime
  #         end = moment newCall.gcal.end.dateTime
  #         expect(end.diff(start, 'hours')).to.equal 4
  #         done()

  # it '2h call exists. schedule 5h, edit to 7hr, expect 3h left', (done) ->
  #   @timeout 10000
  #   user = data.users[14] # tinfow
  #   callp5 = cloneDeep data.calls[5] # domenic
  #   callp5.datetime = new Date(callp5.datetime)
  #   expertId = callp5.expertId # domenic
  #   request = cloneDeep data.requests[14] # tinfow and imageplant
  #   orders = data.orders[8].map(cloneDeep)

  #   requestsSvc.create request, (err, newRequest) =>
  #     saveOrdersForRequest orders, newRequest, (err, newOrders) =>
  #       # console.log JSON.stringify(_.flatten(_.pluck(_.flatten(
  #       #   _.pluck(orders, 'lineItems')), 'redeemedCalls')), null, 2)
  #       c = calcExpertCredit(newOrders, expertId)
  #       expect(c.redeemed).to.equal 2
  #       expect(c.completed).to.equal 0
  #       expect(c.balance).to.equal 10

  #       svc.create user._id, newRequest._id, callp5, (err, results) =>

  #         # not all the orders were modified, so this gives us the big picture
  #         ordersSvc.getByRequestId request._id, (err, orders) =>
  #           if err then return done err
  #           c = calcExpertCredit(orders, expertId)
  #           expect(c.redeemed).to.equal 7
  #           expect(c.completed).to.equal 0
  #           expect(c.balance).to.equal 5
  #           $log 'still going fuck, about to make edits'
  #           makeEdits()

  #   makeEdits = ->
  #     callId = callp5._id
  #     $log 'makeEdis', callId
  #     # let's run thru it like we were a real client!
  #     # hit viewdata for the call and unscheduled orders
  #     viewDataSvc.callEdit null, callId, (err, json) =>

  #       rr = JSON.parse json.request
  #       $log 'request', rr
  #       $log 'request.budget', rr.budget
  #       $log 'request.calls', rr.calls
  #       $log 'request.marketingTags', rr.marketingTags
  #       call = getCall request, callId
  #       $log 'call', call
  #       call.datetime = new Date(call.datetime)
  #       orders = JSON.parse json.orders
  #       ordersWithoutCall = unschedule orders, call._id
  #       # assert that there are no redeemedCalls whose callIds match this call
  #       expect(callInOrders(callId, ordersWithoutCall)).to.equal false
  #       credit = calcExpertCredit ordersWithoutCall, call.expertId
  #       expect(call.type).to.equal 'private'
  #       expect(call.duration).to.equal 5
  #       expect(credit.byType[call.type].balance).to.equal 10

  #       call.duration = 7

  #       # dont let it make calls to google
  #       svc.calendar.google.patchEvent = (eventId, body, cb) ->
  #         cb null, _.extend call.gcal, body
  #       svc.update request.userId, request._id, call, (err, newCall) =>
  #         if err then return done err
  #         expect(newCall.duration).to.equal 7

  #         ordersSvc.getByRequestId request._id, (err, orders) =>
  #           if err then return done err
  #           c = calcExpertCredit(orders, expertId)
  #           expect(c.redeemed).to.equal 9
  #           expect(c.completed).to.equal 0
  #           expect(c.balance).to.equal 3
  #           addRecording(newCall)

    addRecording = (call) ->
      call.recordings = [ { type: 'fake-recording', data: none: true } ]
      svc.update request.userId, request._id, call, (err, newCall) =>
        if err then return done err
        expect(newCall.duration).to.equal 7

        ordersSvc.getByRequestId request._id, (err, orders) =>
          if err then return done err
          c = calcExpertCredit(orders, expertId)
          expect(c.redeemed).to.equal 9
          expect(c.completed).to.equal 7
          expect(c.balance).to.equal 3
          done()
