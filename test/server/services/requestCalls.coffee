{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'

RequestsService = require 'lib/services/requests'
requestsSvc = new RequestsService()

OrdersService = require 'lib/services/orders'
ordersSvc = new OrdersService()
async = require 'async'
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
      ordersSvc.create order, user, cb
    async.map orders, createOrder, callback

  runCreateCallSuccess = (orders, call, done) ->
    requestsSvc.create user, request, (err, newRequest) ->
      if err then done err
      saveOrdersForRequest orders, newRequest, (err, newOrders) ->
        if err then done err
        svc.create user._id, newRequest._id, call, (err, newRequestWithCall) ->
          if err then done err
          expect(newRequestWithCall.calls.length).to.equal 1
          expect(newRequestWithCall.calls[0]).to.be.a 'object'
          newCall = newRequestWithCall.calls[0]
          expect(_.idsEqual newCall.expertId, request.suggested[0].expert._id).to.be.true
          expect(newCall.type).to.equal request.pricing
          done()

  it "cant book a 1hr call without any orders", ->
    call = data.calls[1]
    orders = []
    expect(svc._canScheduleCall orders, call).to.be.false

  it "can book a 1hr call using 1 order and 1 available lineitem for paul", ->
    call = data.calls[1] # expert is paul
    orders = [data.orders[5]] # expert is paul, 2 line items
    expect(svc._canScheduleCall orders, call).to.be.true
  return

  it "can book a 1hr call using 1 order and 1 available lineitem", (done) ->
    @timeout 0
    call = data.calls[1] # expert is paul
    orders = [data.orders[5]] # expert is paul, 2 line items
    runCreateCallSuccess orders, call, done

  it "can book a 2hr call given 2 orders and 2 available lineItems", (done) ->
    @timeout 0
    call = data.calls[2] # duration 2
    orders = [data.orders[5], data.orders[5]]
    runCreateCallSuccess orders, call, done

  it "cannot book a 5hr call given 2 orders and 2 lineItems", (done) ->
    @timeout 0
    call = _.clone data.calls[2]
    call.duration = 5
    orders = [data.orders[5], data.orders[5]]
    requestsSvc.create user, request, (err, newRequest) ->
      if err then done err
      saveOrdersForRequest orders, newRequest, (err, newOrders) ->
        if err then done err
        svc.create user._id, newRequest._id, call, (err, newRequestWithCall) ->
          expect(err).to.exist
          expect(err.message).to.match /Not enough/i
          done()

  it "cannot book a 1hr call given 1 orders and 1 redeemed lineItems", (done) ->
    # prepare a synthetic request object for saving
    requestData = _.clone request
    request.calls = []
    # we want 2 calls with given IDs so we can mark them as redeemed in the order
    request.calls.push _.clone data.calls[1]
    request.calls.push _.clone data.calls[1]
    request.calls[0]._id = new ObjectId
    request.calls[1]._id = new ObjectId
    # save the request to the DB
    requestsSvc.create user, request, (err, newRequest) ->
      if err then done err
      order = _.clone data.orders[5]
      # we want the order to mark both of these calls as already redeemed
      order.lineItems[0].qtyRedeemedCallIds = _.pluck newRequest.calls, "_id"
      # save the order
      saveOrdersForRequest [order], newRequest, (err, newOrders) ->
        if err then done err
        # data.calls[1] has duration 1, which is what we need here
        svc.create user._id, newRequest._id, data.calls[1], (err, newRequestWithCall) ->
          # it should fail because all calls are already redeemed
          expect(err).to.exist
          expect(err.message).to.match /Not enough/i
          done()
