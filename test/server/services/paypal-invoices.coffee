{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'

InvoiceService = require('./../../../lib/services/paypal-invoices')
svc = new InvoiceService()

describe "InvoiceService", ->
  @testNum = 0

  before ->
  after ->
  beforeEach -> @testNum++

  it "can send invoice", (done) ->

    svc.CreateAndSendInvoice (resp) =>
      $log 'resp', resp
      expect( resp.responseEnvelope.ack ).to.equal 'Success'
      done()
