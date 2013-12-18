{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'

RequestsService = require 'lib/services/requests'
requestsSvc = new RequestsService()

OrdersService = require 'lib/services/orders'
ordersSvc = new OrdersService()
async = require 'async'

RequestCallsService = require 'lib/services/requestCalls'
svc = new RequestCallsService()

describe "RequestCallsService", ->
  @testNum = 0

  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach () ->
    @testNum++

  saveOrdersForRequest = (orders, request, user, callback) ->
    createOrder = (order, cb) ->
      order = _.omit order, "_id"
      order.requestId = request._id
      ordersSvc.create order, user, cb
    async.map orders, createOrder, callback

  runCreateCallSuccess = (orders, call, done) ->
    request = data.requests[10] # experts[0] = paul, experts[1] = matthews
    request = _.omit request, "_id"
    user = data.users[13]  # bchristie

    requestsSvc.create user, request, (err, newRequest) ->
      if err then done err
      saveOrdersForRequest orders, newRequest, user, (err, newOrders) ->
        if err then done err
        svc.create user._id, newRequest._id, call, (err, newRequestWithCall) ->
          if err then done err
          expect(newRequestWithCall.calls.length).to.equal 1
          expect(newRequestWithCall.calls[0]).to.be.a 'object'
          newCall = newRequestWithCall.calls[0]
          expect(_.idsEqual newCall.expertId, request.suggested[0].expert._id).to.be.true
          expect(newCall.type).to.equal request.pricing
          done()

  it "can book a 1hr call using 1 order and 1 lineitem", (done) ->
    @timeout 0
    call = data.calls[1] # expert is paul
    orders = [data.orders[5]] # expert is paul, 2 line items
    runCreateCallSuccess orders, call, done

  it "can book a 2hr call given 2 orders and 2 lineItems", (done) ->
    @timeout 0
    call = data.calls[2] # duration 2
    orders = [data.orders[5], data.orders[5]]
    runCreateCallSuccess orders, call, done

  # it "cannot book a 1hr call given 2 orders and 2 completed lineItems", (done) ->


  # it "cannot book a 1hr call given 2 orders and 2 redeemed lineItems", (done) ->
