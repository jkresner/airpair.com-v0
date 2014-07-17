{http,_,sinon,chai,expect} = require '../test-lib-setup'
{app, data, nock} = require '../test-app-setup'

async     = require 'async'
cloneDeep = require 'lodash.clonedeep'
moment    = require 'moment'
ObjectId  = require('mongoose').Types.ObjectId

unschedule       = require '../../../lib/mix/unschedule'
calcExpertCredit = require '../../../lib/mix/calcExpertCredit'
ordersSvc        = new (require '../../../lib/services/orders')(data.users[13])
requestsSvc      = new (require '../../../lib/services/requests')(data.users[13])
viewDataSvc      = new (require '../../../lib/services/_viewdata')(data.users[13])
svc              = new (require '../../../lib/services/requestCalls')()

describe "RequestCallsService", ->
  user = data.users[13]  # bchristie
  request = data.requests[10] # experts[0] = paul, experts[1] = matthews
  request = _.omit request, '_id'

  beforeEach () ->
    nock('https://api.stripe.com:443')
      .post('/v1/charges', "customer=cus_35N03uIhfJPhzU&amount=18000&currency=usd")
      .reply 200,
        {"id":"ch_4NWz6ANL8qUMxC","object":"charge","created":1405015533,"livemode":false,
        "paid":true,"amount":18000,"currency":"usd","refunded":false,
        "card":{"id":"card_35N0JRtcbhMuNs","object":"card","last4":"4242","brand":"Visa","funding":"credit","exp_month":10,"exp_year":2014,"fingerprint":"DMfzzf5aobPBRDZg","country":"US","name":null,"address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":null,"address_line1_check":null,"address_zip_check":null,"customer":"cus_35N03uIhfJPhzU","type":"Visa"},
        "captured":true,"refunds":[],"balance_transaction":"txn_4NWzim2o2r8xRP",
        "failure_message":null,"failure_code":null,"amount_refunded":0,
        "customer":"cus_35N03uIhfJPhzU","invoice":null,"description":null,
        "dispute":null,"metadata":{},"statement_description":null,
        "receipt_email":"bqchristie@gmail.com"}

    nock('https://api.stripe.com:443')
      .post('/v1/charges', "customer=cus_35N03uIhfJPhzU&amount=18000&currency=usd")
      .reply 200,
        {"id":"ch_4NWz6ANL8qUMxC","object":"charge","created":1405015533,"livemode":false,
        "paid":true,"amount":18000,"currency":"usd","refunded":false,
        "card":{"id":"card_35N0JRtcbhMuNs","object":"card","last4":"4242","brand":"Visa","funding":"credit","exp_month":10,"exp_year":2014,"fingerprint":"DMfzzf5aobPBRDZg","country":"US","name":null,"address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":null,"address_line1_check":null,"address_zip_check":null,"customer":"cus_35N03uIhfJPhzU","type":"Visa"},
        "captured":true,"refunds":[],"balance_transaction":"txn_4NWzim2o2r8xRP",
        "failure_message":null,"failure_code":null,"amount_refunded":0,
        "customer":"cus_35N03uIhfJPhzU","invoice":null,"description":null,
        "dispute":null,"metadata":{},"statement_description":null,
        "receipt_email":"bqchristie@gmail.com"}

    @testNum++

  saveOrdersForRequest = (orders, request, callback) ->
    createOrder = (order, cb) ->
      order = _.omit order, '_id'
      order.requestId = request._id
      ordersSvc.create order, (err, newOrder) ->
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
    call = data.calls[2] # duration 2
    orders = [cloneDeep(data.orders[5]), cloneDeep(data.orders[5])]
    runCreateCallSuccess orders, call, done

  it "cannot book a 5hr call given 2 orders and 2 lineItems", (done) ->
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
    callos2 = cloneDeep data.calls[3]
    callp5 = cloneDeep data.calls[4]
    request = cloneDeep data.requests[12]

    orders = [ cloneDeep(data.orders[6]), cloneDeep(data.orders[7]) ]
    nock('https://svcs.sandbox.paypal.com:443')
      .post('/AdaptivePayments/Pay')
      .reply 200,
        ["1f8b08000000000000031d8d410e82301045ef326b3033b491d21dd12e8c1ba25ca096591081125a8cc478778bcbffde4bfe07160eb39f029be9c5839f19f407623f7288769c41438124732c73c2964817a8491c0877a4112103eb9ea9baafce7108693bbf2c3cd8d8fbe9d2254345653bea9c44a564f28fb51ffe1c2b2cc451c13783d96e57de12ac9b5c1a12aa54e2d60859aa4aec1fc98f3c45f366778f36ae21a5a79ba95b7386ef0fa058b06dc3000000"]
    nock('https://svcs.sandbox.paypal.com:443')
      .post('/AdaptivePayments/Pay')
      .reply 200,
        ["1f8b08000000000000031d8d410e82301045ef326b3033b491d21dd12e8c1ba25ca096591081125a8cc478778bcbffde4bfe07160eb39f029be9c5839f19f407623f7288769c41438124732c73c2964817a8491c0877a4112103eb9ea9baafce7108693bbf2c3cd8d8fbe9d2254345653bea9c44a564f28fb51ffe1c2b2cc451c13783d96e57de12ac9b5c1a12aa54e2d60859aa4aec1fc98f3c45f366778f36ae21a5a79ba95b7386ef0fa058b06dc3000000"]


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

