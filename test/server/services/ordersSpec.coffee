{http, _, sinon, chai, expect, Factory} = require './../test-lib-setup'
{app,data,passportMock,nock} = require './../test-app-setup'
{app, data} = require '../test-app-setup'
async = require 'async'

cloneDeep = require('lodash').cloneDeep
ObjectId = require('mongoose').Types.ObjectId
canSchedule = require './../../../lib/mix/canSchedule'

svc = new (require '../../../lib/services/orders')()

describe 'OrdersService', ->
  user = data.users[13]  # bchristie
  request = data.requests[10] # experts[0] = paul, experts[1] = matthews
  request = _.omit request, '_id'

  it "cannot book a 1hr call without any orders", ->
    call = data.calls[1]
    orders = []
    expect(canSchedule orders, call).to.equal false

  it "can book a 1hr call using 1 order and 1 available lineitem for paul", ->
    call = data.calls[1] # expert is paul
    orders = [cloneDeep data.orders[5]] # expert is paul, 2 line items
    expect(canSchedule orders, call).to.equal true

    orders = orders.map (o) ->
      o.markModified = ->
      o

    callId = call._id
    modified = svc._modifyWithDuration orders, call
    expect(modified).to.have.length 1
    expect(modified[0].lineItems[0].redeemedCalls[0].qtyRedeemed).to.equal 1

  it "cannot book a 1hr call given 1 order and 1 redeemed lineItems", ->
    call = data.calls[1] # expert is paul
    orders = [cloneDeep data.orders[5]] # expert is paul, 2 line items

    # mark it completed
    call._id = new ObjectId()
    orders[0].lineItems[0].redeemedCalls.push callId: call._id, qtyRedeemed: call.duration

    expect(canSchedule orders, call).to.equal false

  setupBookme = (withCredit, callback) ->
    ticketRequestId = "53ce8a703441d602008095b6"
    bookMe =
      rate: "200"
      rake: "40"
      urlSlug: "aslak"
      urlBlog: ""
      noIndex: true
      enabled: true
      coupons: []
      creditRequestIds: [ticketRequestId]

    async.parallel [
      (cb) => Factory.create 'user', (@user) => cb()
      (cb) => Factory.create 'user', {googleId: "111111111111"}, (@expertUser) => cb()
    ], =>
      userId = @user._id
      async.parallel [
        (cb) => Factory.create 'aslakExpert', {userId: @expertUser._id, bookMe}, (@expert) => cb()
        (cb) => Factory.create 'settings', {userId}, (@settings) => cb()
      ], =>

        lineItems = [
          type: "ticket"
          total: 1
          unitPrice: 150
          qty: 1
          suggestion:
            suggestedRate: { ticket: { expert: 0 } },
            expert:
              userId: "52b3c4ff66a6f999a465fe3e",
              name: "Ticket",
              username: "airconf",
              rate: 150,
              email: "team@airpair.com",
              pic: "//0.gravatar.com/avatar/543d49f405c7e3cbd78f8e1a6d1c091d"

          type: "credit"
          total: 0
          unitPrice: -280
          qty: 1
          suggestion:
            suggestedRate: { credit: { expert: 0 } },
            expert:
              userId: "52b3c4ff66a6f999a465fe3e",
              name: "Credit",
              username: "paircredit",
              rate: 150,
              email: "team@airpair.com",
              pic: "//0.gravatar.com/avatar/543d49f405c7e3cbd78f8e1a6d1c091d"
        ]
        if withCredit
          Factory.create 'order', {userId, lineItems, requestId: ticketRequestId}, (ticketOrder) =>
            callback(@user, @expert, @expertUser, ticketOrder)
        else
          callback(@user, @expert, @expertUser, null)

  describe '_creditAvailable', ->
    it "shows the available credit for a given request" , (done) ->
      setupBookme true, (user, expert) =>
        suggested =
          expert: expert
          suggestedRate: 220
          expertStatus: "available"
        Factory.create 'request', {userId: user._id, suggested}, (request) =>
          svc._creditAvailable request, (err, credit) =>
            expect(credit).to.equal(-100)
            done()

  describe '_useCredit', ->
    it "adds a line item for used credit on a credit order" , (done) ->
      setupBookme true, (user, expert, expertUser, ticketOrder) =>
        suggested =
          expert: expert
          suggestedRate: 220
          expertStatus: "available"
        Factory.create 'request', {userId: user._id, suggested}, (request) =>
          svc._useCredit request, -100, (err, orders) =>
            expect(orders[0]._id.toString()).to.equal(ticketOrder._id.toString())
            newLineItem = _.last(orders[0].lineItems)
            expect(newLineItem.total).to.equal(100)
            expect(newLineItem.unitPrice).to.equal(100)
            expect(newLineItem.qty).to.equal(1)
            expect(newLineItem.type).to.equal('credit')
            done()

    it "marks the credit order paidout if all the credit is used" , (done) ->
      setupBookme true, (user, expert, expertUser, ticketOrder) =>
        suggested =
          expert: expert
          suggestedRate: 220
          expertStatus: "available"
        Factory.create 'request', {userId: user._id, suggested, budget: 280}, (request) =>
          svc._useCredit request, -280, (err, orders) =>
            expect(orders[0]._id.toString()).to.equal(ticketOrder._id.toString())
            newLineItem = _.last(orders[0].lineItems)
            expect(newLineItem.unitPrice).to.equal(280)
            expect(orders[0].paymentStatus).to.equal('paidout')
            done()

  describe 'confirmBookme', ->
    stripeReply = {
      "id":"ch_4NWz6ANL8qUMxC","object":"charge","created":1405015533,"livemode":false,
      "paid":true,"amount":18000,"currency":"usd","refunded":false,
      "card":{"id":"card_35N0JRtcbhMuNs","object":"card","last4":"4242","brand":"Visa","funding":"credit","exp_month":10,"exp_year":2014,"fingerprint":"DMfzzf5aobPBRDZg","country":"US","name":null,"address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":null,"address_line1_check":null,"address_zip_check":null,"customer":"cus_35N03uIhfJPhzU","type":"Visa"},
      "captured":true,"refunds":[],"balance_transaction":"txn_4NWzim2o2r8xRP",
      "failure_message":null,"failure_code":null,"amount_refunded":0,
      "customer":"cus_35N03uIhfJPhzU","invoice":null,"description":null,
      "dispute":null,"metadata":{},"statement_description":null,
      "receipt_email":"bqchristie@gmail.com"
    }

    it "charges the customer" , (done) ->
      nock('https://api.stripe.com:443')
        .post('/v1/charges', "customer=&amount=30000&currency=usd")
        .reply 200, stripeReply

      setupBookme false, (user, expert, expertUser, ticketOrder) =>
        svc = new (require '../../../lib/services/orders')(expertUser)
        suggested =
          expert: expert
          suggestedRate: 220
          expertStatus: "available"
        Factory.create 'request', {userId: user._id, suggested, budget: 300}, (request) =>
          svc.confirmBookme request, {expertStatus: 'available'}, (err, request) =>
            svc.searchOne { requestId: request._id }, {}, (err, order) =>
              expect(order.total).to.equal(300)
              done()


    it "only charges the remainder after applying credit" , (done) ->
      nock('https://api.stripe.com:443')
        .post('/v1/charges', "customer=&amount=2000&currency=usd")
        .reply 200, stripeReply

      setupBookme true, (user, expert, expertUser, ticketOrder) =>
        svc = new (require '../../../lib/services/orders')(expertUser)
        suggested =
          expert: expert
          suggestedRate: 220
          expertStatus: "available"
        Factory.create 'request', {userId: user._id, suggested, budget: 300}, (request) =>
          svc.confirmBookme request, {expertStatus: 'available'}, (err, request) =>
            svc.searchOne { requestId: request._id }, {}, (err, order) =>
              expect(order.total).to.equal(20)
              done()

