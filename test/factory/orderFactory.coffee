global._ = require 'lodash'
Factory = require('factory-lady')
Order = require('../../lib/models/order')
{ObjectId} = require('mongoose').Types

defaults =
  requestId: new ObjectId()
  userId: new ObjectId()
  company: { name: "TestCo" }
  lineItems: [
    total: 80
    unitPrice: 80
    qty: 1
    redeemedCalls: [
      callId: new ObjectId()
      qtyRedeemed: 1
      qtyCompleted: 1
    ]
    type: "private"
    suggestion: {}
  ]

  utc: new Date()
  total: 80
  profit: 40
  invoice: {}
  paymentType: "stripe"
  payment: {}
  payouts: []
  paymentStatus: "received"
  utm: {}
  owner: "pg"

Factory.define 'order', Order, defaults
