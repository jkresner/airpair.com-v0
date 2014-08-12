{http, _, sinon, chai, expect, Factory} = require './../test-lib-setup'
{app,data,passportMock,nock} = require './../test-app-setup'
{ObjectId} = require('mongoose').Types
async = require 'async'
users = require '../../data/users'

require('./../../../lib/api/requests')(app)
require('./../../../lib/api/orders')(app)

createReq = require('../util/createRequest')(app)

describe "REST api orders", ->
  describe "POST /api/orders", ->
    it "can not create order if not authenticated", (done) ->
      passportMock.setSession 'anon'
      order = data.orders[1]
      http(app).post('/api/orders/')
        .set('Accept', 'application/json')
        .send(order)
        .expect(403)
        .expect({})
        .end done

    it "creates order if authenticated", (done) ->
      @timeout 10000
      passportMock.setSession 'bchristie'
      order = data.orders[1]
      bchristieReq = data.requests[10]

      nock('https://api.stripe.com:443')
        .post('/v1/charges', "customer=cus_35N03uIhfJPhzU&amount=18000&currency=usd")
        .reply 200,
          "id":"ch_4NWrz5w10pkAcu","object":"charge","created":1405015083,
          "livemode":false,"paid":true,"amount":18000,"currency":"usd","refunded":false,
          "card":{"id":"card_35N0JRtcbhMuNs","object":"card","last4":"4242","brand":"Visa","funding":"credit","exp_month":10,"exp_year":2014,"fingerprint":"DMfzzf5aobPBRDZg","country":"US","name":null,"address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":null,"address_line1_check":null,"address_zip_check":null,"customer":"cus_35N03uIhfJPhzU","type":"Visa"},
          "captured":true,"refunds":[],"balance_transaction":"txn_4NWr9UTBH2w769",
          "failure_message":null,"failure_code":null,"amount_refunded":0,
          "customer":"cus_35N03uIhfJPhzU","invoice":null,"description":null,"dispute":null,
          "metadata":{},"statement_description":null,"receipt_email":"bqchristie@gmail.com"

      createReq bchristieReq, (e, req) =>
        order.requestId = req._id
        http(app).post('/api/orders/')
          .set('Accept', 'application/json')
          .send(order)
          .expect(200)
          .end (err, res) =>
            d = res.body
            expect(d)
            expect(d.paymentStatus).to.equal 'received'
            expect(d.profit).to.equal 40
            expect(d.total).to.equal 180
            done()

  describe "GET /api/orders/credit", ->
    it "should get the total amount of credit available to a user", (done) ->
      passportMock.setSession 'jk'
      jkId = users[1]._id
      Factory.create 'dhhExpert', (dhh) =>
        lineItem = {
          total: -80
          unitPrice: -80
          qty: 1
          redeemedCalls: [
            callId: new ObjectId()
            qtyRedeemed: 1
            qtyCompleted: 1
          ]
          type: "credit"
          suggestion: { expert: {_id: dhh._id.toString()} }
        }

        async.parallel [
          (cb) => Factory.create 'order', { userId: jkId, lineItems: [lineItem]}, (order) => cb(null, order)
          (cb) => Factory.create 'order', { userId: jkId, lineItems: [lineItem, _.extend({}, lineItem, {unitPrice: 50, total: 50})]}, (order) => cb(null, order)
          (cb) => Factory.create 'order', { userId: jkId, lineItems: [_.extend({}, lineItem, {type: "private", unitPrice: 150, total: 150})]}, (order) => cb(null, order)
        ], (error, orders) =>
          http(app).get("/api/orders/credit")
            .expect(200)
            .end (err, res) =>
              body = res.body
              requestId = orders[0].requestId
              expect(body.credits[requestId]).to.eq -110
              done()

  describe "GET /api/orders/expert/:expertId", ->
    it "should get orders that an expert was associated with", (done) ->
      passportMock.setSession 'jk'
      async.parallel [
        (cb) => Factory.create 'dhhExpert', (@dhh) => cb()
        (cb) => Factory.create 'aslakExpert', (@aslak) => cb()
        (cb) => Factory.create 'order', cb
      ], =>
        lineItem = {
          total: 80
          unitPrice: 80
          qty: 1
          redeemedCalls: [
            callId: new ObjectId()
            qtyRedeemed: 1
            qtyCompleted: 1
          ]
          type: "private"
          suggestion: { expert: {_id: @dhh._id.toString()} }
        }

        Factory.create 'order', {lineItems: [lineItem]}, (order2) =>
          http(app).get("/api/orders/expert/#{@dhh._id}")
            .expect(200)
            .end (err, res) =>
              body = res.body
              expect(body.length).to.eq 1
              expect(body[0]._id).to.eq order2._id.toString()
              done()
