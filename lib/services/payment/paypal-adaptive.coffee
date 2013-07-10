request = require 'superagent'


config =
  docs:
    Endpoint: 'https://svcs.sandbox.paypal.com/AdaptivePayments'
    PrimaryReceiver: 'jk-facilitator@airpair.com'
    SECURITYUSERID: 'caller_1312486258_biz_api1.gmail.com',
    SECURITYPASSWORD: '1312486294',
    SECURITYSIGNATURE: 'AbtI7HV1xB428VygBUcIhARzxch4AL65.T18CTeylixNNxDZUu0iO87e'
    APPLICATIONID: 'APP-80W284485P519543T'

  test:
    Endpoint: 'https://svcs.sandbox.paypal.com/AdaptivePayments'
    PrimaryReceiver: 'jk-facilitator@airpair.com'
    SECURITYUSERID: 'jk-facilitator_api1.airpair.com',
    SECURITYPASSWORD: '1372567697',
    SECURITYSIGNATURE: 'An5ns1Kso7MWUdW4ErQKJJJ4qi4-AC6a0z5no3hrQwQyUMvBCahLxwBA'
    APPLICATIONID: 'APP-80W284485P519543T'

  prod:
    Endpoint: 'https://svcs.paypal.com/AdaptivePayments'
    PrimaryReceiver: 'jk@airpair.com'
    SECURITYUSERID: 'jk_api1.airpair.com',
    SECURITYPASSWORD: 'CKGLTLST5C2KYCXQ',
    SECURITYSIGNATURE: 'AFcWxV21C7fd0v3bYYYRCpSSRl31AQ3FdahDmrAydOM0v6NUkwsQ2Nug'
    APPLICATIONID: 'APP-7AK038815Y6144228'


payloadDefault =
  actionType:      "PAY_PRIMARY"
  currencyCode:    "USD"
  feesPayer:       "EACHRECEIVER"
  returnUrl:       "http://www.airpair.com/paypal/success"
  cancelUrl:       "http://www.airpair.com/paypal/cancel"
  requestEnvelope: { errorLanguage:"en_US", detailLevel:"ReturnAll" }
  receiverList:    receiver: []


module.exports = class PaypalAdaptive

  cfg: config.test


  constructor: () ->


  Pay: (order, callback) ->
    order.paymentType = 'paypal'
    airpairMargin = order.total
    payload = _.clone payloadDefault
    payload.memo = "$#{total} #{fullName}"   # {orderId}

    for item in order.lineItems
      airpairMargin -= item.total
      payeePaypalEmail = item.suggestion.expert.paymentSettings.paypal.id
      receiverList.receiver.push
        primary:  false
        email:    payeePaypalEmail
        amount:   item.total

    receiverList.receiver.push
      primary:  true
      email:    @cfg.PrimaryReceiver
      amount:   airpairMargin

    @postPayload "#{@cfg.Endpoint}/Pay", payload, callback


  PaymentDetails  : (payKey, callback) ->
    payload = {}
    @postPayload "#{@cfg.Endpoint}/PaymentDetails", payload, callback


  ExecutePayment  : (callback) ->
    payload = {}
    @postPayload "#{@cfg.Endpoint}/ExecutePayment", payload, callback


  postPayload: (endpoint, payload, callback) ->
    request
      .post(endpoint)
      .send(payload)
      .set('X-PAYPAL-SECURITY-USERID', @cfg.SECURITYUSERID)
      .set('X-PAYPAL-SECURITY-PASSWORD', @cfg.SECURITYPASSWORD)
      .set('X-PAYPAL-SECURITY-SIGNATURE', @cfg.SECURITYSIGNATURE)
      .set('X-PAYPAL-REQUEST-DATA-FORMAT', 'JSON')
      .set('X-PAYPAL-RESPONSE-DATA-FORMAT', 'JSON')
      .set('X-PAYPAL-APPLICATION-ID', @cfg.APPLICATIONID)
      .end (res) =>
        callback res.body


# payloadExample1 =
#   actionType:"PAY"
#   currencyCode:"USD"
#   receiverList:
#     receiver:[{"amount":"11.00","email":"rec1_1312486368_biz@gmail.com"}]
#   returnUrl:"http://www.airpair.com/paypal/success"
#   cancelUrl:"http://www.airpair.com/paypal/cancel"
#   requestEnvelope:
#     errorLanguage:"en_US",
#     detailLevel:"ReturnAll"

# payloadExample2 =
#   actionType:"PAY_PRIMARY"
#   currencyCode:"USD"
#   feesPayer:"EACHRECEIVER"
#   memo:"5 hours"
#   receiverList:
#     receiver:[
#       {amount:"600.00",email:"jk-facilitator@airpair.com",primary:true}
#       {amount:"225.00",email:"expert01@airpair.com",primary:false}
#       {amount:"349.00",email:"expert02@airpair.com",primary:false}
#     ]
#   returnUrl:"http://www.airpair.com/paypal/success",
#   cancelUrl:"http://www.airpair.com/paypal/cancel",
#   requestEnvelope:
#     errorLanguage:"en_US",
#     detailLevel:"ReturnAll"



# responseExample1 =
#   responseEnvelope
#     timestamp:      "2011-08-20T15:12:20.833-07:00"
#     ack:            "Success"
#     correlationId:  "nnnnnnnnnnnn"
#     build:          "nnnnnnn"
#   payKey: "Your-payKey"
#   paymentExecStatus: "CREATED"
