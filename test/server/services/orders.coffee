{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require '../test-lib-setup'
{app, data}                                    = require '../test-app-setup'

cloneDeep = require 'lodash.cloneDeep'
ObjectId = require('mongoose').Types.ObjectId
canSchedule          = require './../../../lib/mix/canSchedule'

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
