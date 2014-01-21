{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'

RequestsService = require 'lib/services/requests'
requestsSvc = new RequestsService()

OrdersService = require 'lib/services/orders'
ordersSvc = new OrdersService()

async = require 'async'
cloneDeep = require 'lodash.clonedeep'
ObjectId = require('mongoose').Types.ObjectId

RequestCallsService = require 'lib/services/requestCalls'
svc = new RequestCallsService()

describe "RequestCallsService", ->
  @testNum = 0
  user = data.users[13]  # bchristie
  request = data.requests[10] # experts[0] = paul, experts[1] = matthews
  request = _.omit request, "_id"
  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach () ->
    @testNum++

  saveOrdersForRequest = (orders, request, callback) ->
    createOrder = (order, cb) ->
      order = _.omit order, "_id"
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

  it "cannot book a 1hr call without any orders", ->
    call = data.calls[1]
    orders = []
    expect(svc._canScheduleCall orders, call).to.equal false

  it "can book a 1hr call using 1 order and 1 available lineitem for paul", ->
    call = data.calls[1] # expert is paul
    orders = [cloneDeep data.orders[5]] # expert is paul, 2 line items
    expect(svc._canScheduleCall orders, call).to.equal true

    orders = orders.map (o) ->
      o.markModified = ->
      o
    modified = svc._modifyOrdersWithCallDuration orders, call
    expect(modified).to.have.length 1
    expect(modified[0].lineItems[0].redeemedCalls[0].qtyRedeemed).to.equal 1

  it "cannot book a 1hr call given 1 order and 1 redeemed lineItems", ->
    call = data.calls[1] # expert is paul
    orders = [cloneDeep data.orders[5]] # expert is paul, 2 line items

    # mark it completed
    call._id = new ObjectId()
    orders[0].lineItems[0].redeemedCalls.push callId: call._id, qtyRedeemed: call.duration

    expect(svc._canScheduleCall orders, call).to.equal false

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
    requestsSvc.create user, request, (err, newRequest) ->
      if err then return done err

      saveOrdersForRequest orders, newRequest, (err, newOrders) ->
        if err then return done err
        svc.create user._id, newRequest._id, callos2, (err, results) ->
          if err then return done err
          modifiedRequest = results.request
          modifiedOrders = results.orders
          # it only changes one, but we expect it to change the OSS order
          expect(modifiedOrders.length).to.equal(1)
          expect(modifiedOrders[0].lineItems[0].type).to.equal 'opensource'
          expect(modifiedRequest.calls.length).to.equal 1
          expect(modifiedRequest.calls[0].duration).to.equal 2

          svc.create user._id, newRequest._id, callp5, (err, results) ->
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
            done()
