request = require 'superagent'

payload =
  "requestEnvelope.errorLanguage": "en_US"
  "invoice":
    "merchantEmail": "caller_1335455804_biz@x.com"
    "payerEmail": "jkresner@gmail.com"
    "currencyCode": "USD"
    "paymentTerms": "Net15"
    "itemList":
      "item": [
        {
          "name": "Banana+Leaf+--+001"
          "description": "Banana+Leaf"
          "quantity": "1"
          "unitPrice": "1"
        }
      ]

# https://svcs.sandbox.paypal.com/Invoice/CreateInvoice
# https://svcs.paypal.com/Invoice/{API_operation}

module.exports = class PaypalInvoices
  constructor: () ->

  CreateAndSendInvoice: (callback) ->

    request
      .post("https://svcs.sandbox.paypal.com/Invoice/CreateAndSendInvoice")
      .send(payload)
      .set('X-PAYPAL-SECURITY-USERID', 'caller_1312486258_biz_api1.gmail.com')
      .set('X-PAYPAL-SECURITY-PASSWORD', '1312486294')
      .set('X-PAYPAL-SECURITY-SIGNATURE', 'AbtI7HV1xB428VygBUcIhARzxch4AL65.T18CTeylixNNxDZUu0iO87e')
      .set('X-PAYPAL-REQUEST-DATA-FORMAT', 'JSON')
      .set('X-PAYPAL-RESPONSE-DATA-FORMAT', 'JSON')
      .set('X-PAYPAL-APPLICATION-ID', 'APP-80W284485P519543T')
      .end (res) =>
        callback res.body