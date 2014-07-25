class QueryHelper

  airconf:
    requestId: '53ce8a703441d602008095b6'
    ticketPrice: 150
    pairCredit: 150
    ticketLineItem:
      type: 'ticket'
      total: 1
      unitPrice: 150
      qty: 1
      suggestion:
        suggestedRate: { ticket: { expert: 0 } }
        expert:
          userId:         '52b3c4ff66a6f999a465fe3e' # experts@airpair.com
          name:           'AirConf Ticket'
          username:       'airconf'
          rate:           150
          email:          'team@airpair.com'
          pic:            '//0.gravatar.com/avatar/543d49f405c7e3cbd78f8e1a6d1c091d'
    pairCreditLineItem:
      type: 'credit'
      total: 0
      unitPrice: 0
      qty: 1
      suggestion:
        suggestedRate:  { credit: { expert: 0 } }
        expert:
          userId:         '52b3c4ff66a6f999a465fe3e' # experts@airpair.com
          name:           'redit'
          username:       'paircredit'
          rate:           150
          email:          'team@airpair.com'
          pic:            '//0.gravatar.com/avatar/543d49f405c7e3cbd78f8e1a6d1c091d'
          #paymentMethod:  "type": "credit", "info": { "email": "" }


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
