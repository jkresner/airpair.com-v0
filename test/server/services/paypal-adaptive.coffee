{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app,data,passportMock} = require './../test-app-setup'

PaypalService = require('../../../lib/services/payment/paypal-adaptive')
svc = new PaypalService()

describe "PaypalService", ->
  @testNum = 0

  before ->
  after ->
  beforeEach -> @testNum++

  it "should payout adaptive, but fail b/c customer never paid", (done) ->
    this.timeout 2000
    order = data.orders[3]

    svc.Pay order, (e, res) ->
      if e then return done e
      expect(res.responseEnvelope.ack).to.equal 'Success'
      expect(res.paymentExecStatus).to.equal 'CREATED'

      o = { payment: { payKey: res.payKey } }
      svc.ExecutePayment o, (e, res2) ->
        if e then return done e

        console.log('sep res', JSON.stringify(res2, null, 2))
        expect(res2.responseEnvelope.ack).to.equal 'Failure'
        expect(res2.error.length).to.equal 1
        msg = "This payment request must be authorized by the sender"
        expect(res2.error[0].message).to.equal msg
        done()

  it "should payout a single expert", (done) ->
    this.timeout 4000
    order = data.orders[2]
    lineItem = order.lineItems[0]

    svc.PaySingle order, lineItem, (e, req, res) ->
      if e then return done e
      expect(req.receiverList.receiver[0].email).to.equal 'expert02@airpair.com'
      expect(res.responseEnvelope.ack).to.equal 'Success'
      expect(res.paymentExecStatus).to.equal 'COMPLETED'
      expect(res.paymentInfoList.paymentInfo[0].transactionStatus).to.equal 'COMPLETED'
      expect(res.paymentInfoList.paymentInfo[0].receiver.primary).to.equal 'false'
      expect(res.paymentInfoList.paymentInfo[0].senderTransactionStatus).to.equal 'COMPLETED'
      done()
