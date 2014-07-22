class QueryHelper

  airconf:
    requestId: '53ce8a703441d602008095b6'
    pairCredit: 150

  query: {}

  view:

    # /history by customer
    history:
      '_id': 1
      'lineItems': 1
      'lineItems.completed': 1
      'lineItems.qty': 1
      'lineItems.unitPrice': 1
      'lineItems.redeemedCalls': 1
      'lineItems.total': 1
      'lineItems.suggestion.expert': 1
      'owner': 1
      'paymentStatus': 1
      'paymentType': 1
      'requestId': 1
      'total': 1
      'userId': 1
      'utc': 1


module.exports = new QueryHelper()
