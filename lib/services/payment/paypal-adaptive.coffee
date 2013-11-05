request = require 'superagent'

config =
  dev:
    AP: 'http://localhost:3333'
    Endpoint: 'https://svcs.sandbox.paypal.com/AdaptivePayments'
    PrimaryReceiver: 'jk-facilitator@airpair.com'
    SECURITYUSERID: 'jk-facilitator_api1.airpair.com',
    SECURITYPASSWORD: '1372567697',
    SECURITYSIGNATURE: 'An5ns1Kso7MWUdW4ErQKJJJ4qi4-AC6a0z5no3hrQwQyUMvBCahLxwBA'
    APPLICATIONID: 'APP-80W284485P519543T'

  prod:
    AP: 'https://www.airpair.com'
    Endpoint: 'https://svcs.paypal.com/AdaptivePayments'
    PrimaryReceiver: 'jk@airpair.com'
    SECURITYUSERID: 'jk_api1.airpair.com',
    SECURITYPASSWORD: 'CKGLTLST5C2KYCXQ',
    SECURITYSIGNATURE: 'AFcWxV21C7fd0v3bYYYRCpSSRl31AQ3FdahDmrAydOM0v6NUkwsQ2Nug'
    APPLICATIONID: 'APP-7AK038815Y6144228'

getEnvConfig = (config) ->
  env = process.env.Payment_Env
  if env? && env is 'prod' then return config.prod
  cfg = config.dev
  if env? && env is 'staging' then cfg.AP = 'http://staging.airpair.com'
  if env? && env is 'test' then cfg.AP = 'http://localhost:4444'
  cfg

payloadDefault = (cfg) ->
  actionType:      "PAY_PRIMARY"
  currencyCode:    "USD"
  feesPayer:       "EACHRECEIVER"
  returnUrl:       "#{cfg.AP}/paypal/success/"
  cancelUrl:       "#{cfg.AP}/paypal/cancel/"
  requestEnvelope: { errorLanguage:"en_US", detailLevel:"ReturnAll" }
  receiverList:    receiver: []

getExpertPaypalEmail = (item) ->
  env = process.env.Payment_Env
  if env? && env is 'prod'
    item.suggestion.expert.paymentMethod.info.email
  else
    "expert02@airpair.com"


module.exports = class PaypalAdaptive

  cfg: getEnvConfig(config)

  constructor: () ->

  Pay: (order, callback) ->
    order.paymentType = 'paypal'
    payload = payloadDefault(@cfg)
    payload.memo = "https://airpair.com/review/#{order.requestId}"

    for item in order.lineItems
      payeePaypalEmail = getExpertPaypalEmail(item)
      payload.receiverList.receiver.push
        primary:  false
        email:    payeePaypalEmail
        amount:   @formatCurrency(item.expertsTotal)

    payload.receiverList.receiver.push
      primary:  true
      email:    @cfg.PrimaryReceiver
      amount:   @formatCurrency(order.total)

    payload.returnUrl += order._id
    payload.cancelUrl += order._id

    @postPayload "Pay", payload, callback


  PaymentDetails: (order, callback) ->
    payload =
      requestEnvelope: { errorLanguage:"en_US", detailLevel:"ReturnAll" }
      payKey: order.payment.payKey

    @postPayload "PaymentDetails", payload, callback


  ExecutePayment: (order, callback) ->
    payload =
      requestEnvelope: { errorLanguage:"en_US", detailLevel:"ReturnAll" }
      payKey: order.payment.payKey

    @postPayload "ExecutePayment", payload, callback


  postPayload: (operation, payload, callback) ->
    endpoint = "#{@cfg.Endpoint}/#{operation}"
    winston.log "PayalPost: #{endpoint}", payload
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
        if cfg.isProd
          $log "PayalResponse: #{endpoint}", payload, res.body
          winston.log "PayalResponse: #{endpoint}", res.body
        callback res.body

  formatCurrency: (num) =>
    num = (if isNaN(num) or num is "" or num is null then 0.00 else num)
    parseFloat(num).toFixed(2)

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
