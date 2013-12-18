{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'

RequestsService = require 'lib/services/requests'
requestsSvc = new RequestsService()

OrdersService = require 'lib/services/orders'
ordersSvc = new OrdersService()

RequestCallsService = require 'lib/services/requestCalls'
svc = new RequestCallsService()

describe "RequestCallsService", ->
  @testNum = 0

  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach () ->
    @testNum++

  runCreateCallSuccess = (order, done) ->
    request = data.requests[10] # experts[0] = paul, experts[1] = matthews
    user = data.users[13]  # bchristie
    call = data.calls[1] # expert is paul

    requestsSvc.create user, request, (err, newRequest) ->
      if err then done err
      order.requestId = newRequest._id
      ordersSvc.create order, user, (err, newOrder) ->
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
    order = data.orders[5] # expert is paul, 2 line items
    runCreateCallSuccess order, done

  it "can book a 2hr call given 2 orders and 2 lineItems", (done) ->
    @timeout 0
    runCreateCallSuccess data.orders[5], done

  # it "cannot book a 1hr call given 2 orders and 2 completed lineItems", (done) ->

  # it "cannot book a 1hr call given 2 orders and 2 redeemed lineItems", (done) ->
