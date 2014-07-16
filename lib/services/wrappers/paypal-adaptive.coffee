request = require 'superagent'

payloadDefault = ->
  actionType:      "PAY_PRIMARY"
  currencyCode:    "USD"
  feesPayer:       "EACHRECEIVER"
  returnUrl:       "#{config.oauthHost}/paypal/success/"
  cancelUrl:       "#{config.oauthHost}/paypal/cancel/"
  requestEnvelope: { errorLanguage:"en_US", detailLevel:"ReturnAll" }
  receiverList:    receiver: []

getExpertPaypalEmail = (item) ->
  env = process.env.Payment_Env
  if env? && env is 'prod'
    item.suggestion.expert.paymentMethod.info.email
  else
    "expert02@airpair.com"


module.exports = class PaypalAdaptive

  settings: _.clone(config.payment.paypal)

  constructor: () ->

  Pay: (order, callback) ->
    order.paymentType = 'paypal'
    payload = payloadDefault()
    payload.memo = "https://airpair.com/review/#{order.requestId}"

    for item in order.lineItems
      payeePaypalEmail = getExpertPaypalEmail(item)
      payload.receiverList.receiver.push
        primary:  false
        email:    payeePaypalEmail
        amount:   @formatCurrency(item.expertsTotal)

    payload.receiverList.receiver.push
      primary:  true
      email:    @settings.primaryReceiver
      amount:   @formatCurrency(order.total)

    payload.returnUrl += order._id
    payload.cancelUrl += order._id

    @postPayload "Pay", payload, callback

  PaySingle: (order, lineItem, callback) ->
    payload = payloadDefault()
    payload.memo = "https://airpair.com/review/#{order.requestId}"
    payload.actionType = 'PAY'
    payload.senderEmail = @settings.primaryReceiver

    payeePaypalEmail = getExpertPaypalEmail(lineItem)
    payload.receiverList.receiver.push
      email:    payeePaypalEmail
      amount:   @formatCurrency(lineItem.expertsTotal)

    @postPayload "Pay", payload, (e, res) ->
      return callback e, payload, res

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
    endpoint = "#{@settings.endpoint}/#{operation}"
    winston.log "PayalPost: #{endpoint}", payload
    request
      .post(endpoint)
      .send(payload)
      .set('X-PAYPAL-SECURITY-USERID', @settings.SECURITYUSERID)
      .set('X-PAYPAL-SECURITY-PASSWORD', @settings.SECURITYPASSWORD)
      .set('X-PAYPAL-SECURITY-SIGNATURE', @settings.SECURITYSIGNATURE)
      .set('X-PAYPAL-REQUEST-DATA-FORMAT', 'JSON')
      .set('X-PAYPAL-RESPONSE-DATA-FORMAT', 'JSON')
      .set('X-PAYPAL-APPLICATION-ID', @settings.APPLICATIONID)
      .end (err, res) =>
        if err then return callback err
        if config.isProd
          $log "PayalResponse: #{endpoint}", payload, res.body
          winston.log "PayalResponse: #{endpoint}", res.body
        callback null, res.body

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

###
PaySingle examples:
Request for an implicitly approved payment:

"actionType=PAY
&senderEmail=sender@domain
&cancelUrl=http://your_cancel_url
&currencyCode=USD
&receiverList.receiver(0).email=receiver@domain
&receiverList.receiver(0).amount=100.00
&requestEnvelope.errorLanguage=en_US
&returnUrl=http://your_return_url"


Response for an implicitly approved payment:

responseEnvelope.timestamp=2013-04-24T14%3A39%3A26.000-07%3A00
&responseEnvelope.ack=Success
&responseEnvelope.correlationId=34e44c0bdbed6
&responseEnvelope.build=5710123
&payKey=AP-54224401WG0931234
&paymentExecStatus=COMPLETED
&paymentInfoList.paymentInfo(0).transactionId=1F809595PU5211234
&paymentInfoList.paymentInfo(0).transactionStatus=COMPLETED
&paymentInfoList.paymentInfo(0).receiver.amount=100.00
&paymentInfoList.paymentInfo(0).receiver.email=receiver@domain
&paymentInfoList.paymentInfo(0).receiver.primary=false
&paymentInfoList.paymentInfo(0).receiver.accountId=7X2XKABC5Z1234
&paymentInfoList.paymentInfo(0).pendingRefund=false
&paymentInfoList.paymentInfo(0).senderTransactionId=5VA331617X3361234
&paymentInfoList.paymentInfo(0).senderTransactionStatus=COMPLETED
&sender.accountId=6VJKLRUABCDEF
###
