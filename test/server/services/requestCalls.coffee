{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require '../test-lib-setup'

# NOTE: this causes mocha-phantom to hang instead of exiting!
# chai.Assertion.includeStack = true;

{app, data} = require '../test-app-setup'

async = require 'async'
cloneDeep = require 'lodash.clonedeep'
moment = require 'moment'
ObjectId = require('mongoose').Types.ObjectId

expertCredit = require '../../../app/scripts/shared/mix/expertCredit'
ordersSvc = new (require '../../../lib/services/orders')()
requestsSvc = new (require '../../../lib/services/requests')()
viewDataSvc = new (require '../../../lib/services/_viewdata')()
svc = new (require '../../../lib/services/requestCalls')()

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
    requestsSvc.create user, request, (err, newRequest) ->
      if err then return callback err
      saveOrdersForRequest orders, newRequest, (err, __) ->
        if err then return callback err
        svc.create user._id, newRequest._id, call, (err, results) ->
          if err then return callback err
          newRequestWithCall = results.request
          expect(newRequestWithCall).to.be.a 'object'
          expect(newRequestWithCall.calls.length).to.equal 1
          expect(newRequestWithCall.calls[0]).to.be.a 'object'
          newCall = newRequestWithCall.calls[0]
          expect(_.idsEqual newCall.expertId, request.suggested[0].expert._id).to.be.true
          expect(newCall.type).to.equal request.pricing
          return callback null, results.orders, newRequestWithCall, newCall

  it "can book a 1hr call using 1 order and 1 available lineitem", (done) ->
    @timeout 10000
    call = data.calls[1] # expert is paul
    orders = [cloneDeep data.orders[5]] # expert is paul, 2 line items
    runCreateCallSuccess orders, call, (err, newOrders, newRequestWithCall, newCall) ->
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
    requestsSvc.create user, request, (err, newRequest) ->
      if err then return done err
      saveOrdersForRequest orders, newRequest, (err, newOrders) ->
        if err then return done err
        svc.create user._id, newRequest._id, call, (err, newRequestWithCall) ->
          expect(err).to.exist
          expect(err.message).to.match /Not enough/i
          done()

  it "can book a 2 hour open source session and then a 5 hour private session", (done) ->
    @timeout 10000
    callos2 = cloneDeep data.calls[3]
    callp5 = cloneDeep data.calls[4]
    request = cloneDeep data.requests[12]

    orders = [ cloneDeep(data.orders[6]), cloneDeep(data.orders[7]) ]
    requestsSvc.create user, request, (err, newRequest) =>
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

  it 'can edit a 2hr OSS call and a 5hr private call down to 1hr then the private back to 4hr', (done) ->
    @timeout 10000
    callId1 = @modifiedRequest.calls[0]._id
    callId2 = @modifiedRequest.calls[1]._id

    # let's run thru it like we were a real client!
    # hit viewdata for the call and unscheduled orders
    viewDataSvc.callEdit callId1, (err, json) =>
      if err then return done err
      request = JSON.parse json.request
      call = getCall request, callId1
      ordersWithoutCall = JSON.parse json.orders
      # assert that there are no redeemedCalls whose callIds match this call
      expect(callInOrders(callId1, ordersWithoutCall)).to.equal false
      credit = expertCredit ordersWithoutCall, call.expertId
      expect(call.type).to.equal 'opensource'
      expect(credit.byType[call.type].balance).to.equal 2

      # change the duration to 1, and the time just for kicks, and also the note
      call.duration = 1
      hammerTime = new Date()
      call.datetime = hammerTime
      badassNotes = 'waddup im editing you for the first time ever'
      call.notes = badassNotes

      # dont let it make calls to google
      svc.calendar.google.patchEvent = (eventId, body, cb) ->
        cb null, _.extend call.gcal, body
      svc.update request.userId, request._id, call, (err, newCall) =>
        if err then return done err
        # assert gcal duration is changed using moment.diff
        # assert start time is different
        # assert note is the same
        expect(newCall.duration).to.equal 1
        expect(newCall.notes).to.equal badassNotes
        expect(newCall.datetime.getTime()).to.equal hammerTime.getTime()
        start = moment newCall.gcal.start.dateTime
        end = moment newCall.gcal.end.dateTime
        expect(end.diff(start, 'hours')).to.equal 1
        nextEdit()

    nextEdit = ->
      # hit viewdata for call2
      viewDataSvc.callEdit callId2, (err, json) =>
        if err then return done err
        request = JSON.parse json.request
        call = getCall request, callId2
        ordersWithoutCall = JSON.parse json.orders
        # assert call2 is not in the orders
        expect(callInOrders(callId2, ordersWithoutCall)).to.equal false
        credit = expertCredit ordersWithoutCall, call.expertId
        # assert that the OSS credit is 1hr
        expect(credit.byType['opensource'].balance).to.equal 1
        # assert that the private credit is 5hr
        expect(call.type).to.equal 'private'
        expect(credit.byType[call.type].balance).to.equal 5

        # change the duration to 1, and the time just for kicks, and also the note
        call.duration = 1
        hammerTime = new Date()
        call.datetime = hammerTime
        badassNotes = 'waddup this is the second time ive ever edited a call'
        call.notes = badassNotes
        svc.update request.userId, request._id, call, (err, newCall) =>
          if err then return done err
          # assert gcal duration is changed using moment.diff
          # assert start time is different
          # assert note is the same
          expect(newCall.duration).to.equal 1
          expect(newCall.notes).to.equal badassNotes
          expect(newCall.datetime.getTime()).to.equal hammerTime.getTime()
          start = moment newCall.gcal.start.dateTime
          end = moment newCall.gcal.end.dateTime
          expect(end.diff(start, 'hours')).to.equal 1
          lastEdit()

    lastEdit = ->
      # switch the private call to duration 4
      viewDataSvc.callEdit callId2, (err, json) =>
        if err then return done err
        request = JSON.parse json.request
        call = getCall request, callId2
        ordersWithoutCall = JSON.parse json.orders
        # assert call2 is not in the orders
        expect(callInOrders(callId2, ordersWithoutCall)).to.equal false
        credit = expertCredit ordersWithoutCall, call.expertId
        # assert that the OSS credit is 1hr
        expect(credit.byType['opensource'].balance).to.equal 1
        # assert that the private credit is 5hr
        expect(call.type).to.equal 'private'
        expect(credit.byType[call.type].balance).to.equal 5

        call.datetime = new Date()
        call.duration = 4
        svc.update request.userId, request._id, call, (err, newCall) =>
          if err then return done err
          expect(newCall.duration).to.equal 4
          start = moment newCall.gcal.start.dateTime
          end = moment newCall.gcal.end.dateTime
          expect(end.diff(start, 'hours')).to.equal 4
          done()
