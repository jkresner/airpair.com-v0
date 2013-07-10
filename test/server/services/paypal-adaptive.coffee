{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'

AdaptiveService = require('./../../../lib/services/payment/paypal-adaptive')
svc = new AdaptiveService()

describe "AdaptiveService", ->
  @testNum = 0

  before ->
  after ->
  beforeEach -> @testNum++

  it "can send adaptive payment payment", (done) ->

    svc.Pay (resp) =>
      $log 'response', resp
      expect( resp.responseEnvelope.ack ).to.equal 'Success'
      done()
