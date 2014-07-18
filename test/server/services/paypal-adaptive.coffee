{http, _, sinon, chai, expect} = require './../test-lib-setup'
{app, data, passportMock, nock} = require './../test-app-setup'

PaypalService = require('../../../lib/services/wrappers/paypal-adaptive')
svc = new PaypalService()

before ->
  nock('https://svcs.sandbox.paypal.com:443')
    .post('/AdaptivePayments/Pay', {"actionType":"PAY_PRIMARY","currencyCode":"USD","feesPayer":"EACHRECEIVER","returnUrl":"http://localhost:4444/paypal/success/52a79dc7a45edbed22000018","cancelUrl":"http://localhost:4444/paypal/cancel/52a79dc7a45edbed22000018","requestEnvelope":{"errorLanguage":"en_US","detailLevel":"ReturnAll"},"receiverList":{"receiver":[{"primary":false,"email":"expert02@airpair.com","amount":"80.00"},{"primary":true,"email":"jk-facilitator@airpair.com","amount":"160.00"}]},"memo":"https://airpair.com/review/52a79dc7a45edbed22000017"})
    .reply(200, ["1f8b0800000000000003258ac10e82301005ff65cf60ba6d05ca8d2807c3c5087e402d6b42044a683112c2bfdb68f22e6f663698c94d7674548e6feaed44906fe0bb819cd7c3043970863266698c69832c0f93f220b80828670c22d0e615aa7a31869c0bdfd879a65efbce8e97361864bc45de26fa892d06ff58bafecf15e322c9608f60d26b456b80c53546c19552597aaf501d859419fcfc40a32f3f646aaffde2427aba9545539e61ff02deb8064fc3000000"],
       {
         date: 'Thu, 17 Jul 2014 17:13:07 GMT', server: 'Apache-Coyote/1.1',
         'x-ebay-soa-request-id': '14745502-b8c0-a486-d655-3271ff18f29e!AdaptivePayments!10.72.109.101![]',
         'x-paypal-service-version': '1.0.0',
         'x-paypal-service-name': '{http://svcs.paypal.com/types/ap}AdaptivePayments',
         'x-ebay-soa-response-data-format': 'JSON',
         'x-paypal-operation-name': 'Pay',
         'x-ebay-soa-message-protocol': 'NONE',
         'content-type': 'application/json;charset=UTF-8',
         'set-cookie': [ 'Apache=10.72.109.11.1405617187722324; path=/; expires=Sat, 09-Jul-44 17:13:07 GMT' ],
         vary: 'Accept-Encoding',
         'content-encoding': 'gzip',
         'content-length': '178',
         connection: 'close'
        }
      )

  nock('https://svcs.sandbox.paypal.com:443')
    .post('/AdaptivePayments/ExecutePayment', {"requestEnvelope":{"errorLanguage":"en_US","detailLevel":"ReturnAll"},"payKey":"AP-13299987UK1953448"})
    .reply(200, ["1f8b0800000000000003658fcb6ac33010457f45cc3a29f2ab71bccb2281424b4bf1ae7431b68758c496543d02aef1bf77ec4237053148e7ce1dcd9dc191b7467b3aeb3b0dc61254330435920f385aa8209549be97877d72a81359f1c98b874caea892127680ed8dbb2ea886e888dfad718e060ccae8a78e95b2c4b4391e132c33cc596fa21a569ec8a34cb3c712961d9073c641f531ffde365f5148291336746644a599bc3d9feacbebfb0b331f9b3f7cb27650edf6e1aad09d9c0a130be76d2a6f8481aec64dff7a39a4c72b2786ba575e589c46d24138fa8a1c5f8c914b430263e88d53dfd4896612a127e14977e460f95c7e00c72111c340010000"],
      {
        date: 'Thu, 17 Jul 2014 17:13:08 GMT',
        server: 'Apache-Coyote/1.1',
        'x-ebay-soa-request-id': '14745502-e6f0-a486-d655-3271ff18f29b!AdaptivePayments!10.72.109.101![]',
        'x-paypal-service-version': '1.0.0',
        'x-paypal-service-name': '{http://svcs.paypal.com/types/ap}AdaptivePayments',
        'x-ebay-soa-response-data-format': 'JSON',
        'x-paypal-operation-name': 'ExecutePayment',
        'cache-control': 'no-cache',
        'x-paypal-error-response': 'TRUE',
        'x-ebay-soa-message-protocol': 'NONE',
        'content-type': 'application/json;charset=UTF-8',
        'set-cookie': [ 'Apache=10.72.109.11.1405617188461528; path=/; expires=Sat, 09-Jul-44 17:13:08 GMT' ],
        vary: 'Accept-Encoding',
        'content-encoding': 'gzip',
        'content-length': '254',
        connection: 'close'
      }
    )

  nock('https://svcs.sandbox.paypal.com:443')
    .post('/AdaptivePayments/Pay', {"actionType":"PAY","currencyCode":"USD","feesPayer":"EACHRECEIVER","returnUrl":"http://localhost:4444/paypal/success/","cancelUrl":"http://localhost:4444/paypal/cancel/","requestEnvelope":{"errorLanguage":"en_US","detailLevel":"ReturnAll"},"receiverList":{"receiver":[{"email":"expert02@airpair.com","amount":"140.00"}]},"memo":"https://airpair.com/review/52a7a19f04d3d0b22300003f","senderEmail":"jk-facilitator@airpair.com"})
    .reply(200, ["1f8b08000000000000036d515d4fc32014fd2f3c6fcb05dad1f6c939b7641f46dd971ae303a37786d8d206e8a231fbefd226ea6296c003e71c0ee75cbe88455757c6e1c41cb1a86a24d917f1ba44e76559938c30a0511f449f8a0d852cac28198818029401901e91ea3da8d68d52e85c38abca5a2ca4d79599e581515ce439673c8574af02bf6f74d1e21452607c9890538fd4f273819f011cddf7d3b18034e643368f81c6096c49c79768fce403d5da4bdfb8201ddfddde2f279bc9cd1f3f33876aa99d6f2b9c41247b0995ac344eaadf586cb5e66c48c5e2268e415060c1e64c73f1198b0af5116deb2fcbaa31beed11c1a01b0496521701c08f1aad077625b5adc31ea8aa6c335a5d4adb963cc8c2613739d57a7471aed3e1f568bc996ea76cfad08d044daecddb0a0f8dc9cf2eb980a3ddfc6f2356228968b25b730e8cf2ed25e5854ea7d7d38fb02b759668fe34de3d46bbe7d16a310d9f74fa06bc4ea1292a020000"],
      {
        date: 'Thu, 17 Jul 2014 17:13:09 GMT',
        server: 'Apache-Coyote/1.1',
        'x-ebay-soa-request-id': '14745502-b800-a486-d655-3271ff18f29f!AdaptivePayments!10.72.109.101![]',
        'x-paypal-service-version': '1.0.0',
        'x-paypal-service-name': '{http://svcs.paypal.com/types/ap}AdaptivePayments',
        'x-ebay-soa-response-data-format': 'JSON',
        'x-paypal-operation-name': 'Pay',
        'x-ebay-soa-message-protocol': 'NONE',
        'content-type': 'application/json;charset=UTF-8',
        'set-cookie': [ 'Apache=10.72.109.11.1405617187709741; path=/; expires=Sat, 09-Jul-44 17:13:07 GMT' ],
        vary: 'Accept-Encoding',
        'content-encoding': 'gzip',
        'content-length': '359',
        connection: 'close'
      }
    )

describe "PaypalService", ->
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
