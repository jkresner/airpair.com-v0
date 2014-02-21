users    = require './users'
ObjectId = (s) -> s
ISODate  = (s) -> s

module.exports = [

  # 0) not used
  {}

  # 1) bchristie from the stripe story (for testing api/orders)
  {"total":180,"requestId":"52a4ba0991935b000000002d","lineItems":[{"type":"opensource","total":180,"unitPrice":90,"qty":2,"suggestion":{"_id":"52445f41d81957020000000a","suggestedRate":{"opensource":{"expert":70,"total":90},"private":{"expert":70,"total":110},"nda":{"expert":90,"total":160}},"expert":{"_id":"52372c73a9b270020000001c","userId":"52372c3366a6f999a465f804","name":"Paul Canavese","username":"canavese","rate":70,"email":"paul@canavese.org","pic":"https://secure.gravatar.com/avatar/af2766a3f9d6f81447da51e0d9af9e67","paymentMethod":{"type":"paypal","info":{"email":"consulting@canaveses.org"}}}}}],"company":{"_id":"52a4ba0991935b000000002b","name":"Bruce Christie","contacts":[{"fullName":"bruce christie","email":"bqchristie@gmail.com","gmail":"bqchristie@gmail.com","title":"","phone":"","userId":"5244496866a6f999a465f877","pic":"https://lh6.googleusercontent.com/-Vwjei17buyc/AAAAAAAAAAI/AAAAAAAAAAA/VzQekIoMebs/photo.jpg","twitter":"","timezone":"GMT-0800 (PST)","_id":"52a4ba0991935b000000002c","firstName":"bruce"}]},"paymentMethod":{"type":"stripe","info":{"default_card":"card_35N0JRtcbhMuNs","cards":{"data":[{"address_zip_check":null,"address_line1_check":null,"cvc_check":"pass","address_country":null,"address_zip":null,"address_state":null,"address_city":null,"address_line2":null,"address_line1":null,"name":null,"country":"US","customer":"cus_35N03uIhfJPhzU","fingerprint":"DMfzzf5aobPBRDZg","exp_year":2014,"exp_month":10,"type":"Visa","last4":"4242","object":"card","id":"card_35N0JRtcbhMuNs"}],"url":"/v1/customers/cus_35N03uIhfJPhzU/cards","count":1,"object":"list"},"account_balance":0,"discount":null,"subscription":null,"delinquent":false,"email":"bqchristie@gmail.com","description":null,"livemode":false,"id":"cus_35N03uIhfJPhzU","created":1386527228,"object":"customer"},"isPrimary":true}}

  # 2) bchristie from the stripe story once it is in the DB
  {
    "total": 180,
    "requestId": "52a7a19f04d3d0b22300003f",
    "lineItems": [{
      "type": "opensource",
      "total": 180,
      "unitPrice": 90,
      "qty": 2,
      "redeemedCalls": []
      "suggestion": {
        "_id": "52445f41d81957020000000a",
        "suggestedRate": {
          "opensource": {
            "expert": 70,
            "total": 90
          },
          "private": {
            "expert": 70,
            "total": 110
          },
          "nda": {
            "expert": 90,
            "total": 160
          }
        },
        "expert": {
          "_id": "52372c73a9b270020000001c",
          "userId": "52372c3366a6f999a465f804",
          "name": "Paul Canavese",
          "username": "canavese",
          "rate": 70,
          "email": "paul@canavese.org",
          "pic": "https://secure.gravatar.com/avatar/af2766a3f9d6f81447da51e0d9af9e67",
          "paymentMethod": {
            "type": "paypal",
            "info": {
              "email": "consulting@canaveses.org"
            }
          }
        }
      },
      "expertsTotal": 140
    }],
    "company": {
      "_id": "52a7a19f04d3d0b22300003d",
      "name": "Bruce Christie",
      "contacts": [{
        "fullName": "bruce christie",
        "email": "bqchristie@gmail.com",
        "gmail": "bqchristie@gmail.com",
        "title": "",
        "phone": "",
        "userId": "5244496866a6f999a465f877",
        "pic": "https://lh6.googleusercontent.com/-Vwjei17buyc/AAAAAAAAAAI/AAAAAAAAAAA/VzQekIoMebs/photo.jpg",
        "twitter": "",
        "timezone": "GMT-0800 (PST)",
        "_id": "52a7a19f04d3d0b22300003e",
        "firstName": "bruce"
      }]
    },
    "paymentMethod": {
      "type": "stripe",
      "info": {
        "default_card": "card_36CBsi5Clcjpid",
        "cards": {
          "data": [{
            "address_zip_check": null,
            "address_line1_check": null,
            "cvc_check": "pass",
            "address_country": null,
            "address_zip": null,
            "address_state": null,
            "address_city": null,
            "address_line2": null,
            "address_line1": null,
            "name": null,
            "country": "US",
            "customer": "cus_36CB1AKlt0E8RC",
            "fingerprint": "DMfzzf5aobPBRDZg",
            "exp_year": 2014,
            "exp_month": 10,
            "type": "Visa",
            "last4": "4242",
            "object": "card",
            "id": "card_36CBsi5Clcjpid"
          }],
          "url": "/v1/customers/cus_36CB1AKlt0E8RC/cards",
          "count": 1,
          "object": "list"
        },
        "account_balance": 0,
        "discount": null,
        "subscription": null,
        "delinquent": false,
        "email": "bqchristie@gmail.com",
        "description": null,
        "livemode": false,
        "id": "cus_36CB1AKlt0E8RC",
        "created": 1386717599,
        "object": "customer"
      },
      "isPrimary": true,
      "_id": "52a7a19f04d3d0b22300003c"
    },
    "_id": "52a7a19f04d3d0b223000040",
    "userId": "5244496866a6f999a465f877",
    "invoice": {},
    "profit": 40
  }

  # 3) from book_test.coffee, paying out all experts in an adaptive payment
  # (here we only have one expert, but that does not matter, it's still an
  # adaptive payment)
  {"total":160,"requestId":"52a79dc7a45edbed22000017","lineItems":[{"type":"private","total":160,"unitPrice":80,"qty":2,"suggestion":{"_id":"51b2087622ddda0200000004","suggestedRate":{"opensource":{"expert":40,"total":60},"private":{"expert":40,"total":80},"nda":{"expert":60,"total":130}},"expert":{"_id":"51a4d2b47021eb0200000009","userId":"51a4d2a466a6f999a465f2f1","name":"Richard Kuo","username":"richkuo","rate":"70","email":"richard.p.kuo@gmail.com","pic":"https://secure.gravatar.com/avatar/10f800e74ff94ada0ef4cb483d183939"}},"expertsTotal":80}],"company":{"_id":"51af95ea900c860200000005","name":"WPack","contacts":[{"_id":"51af95ea900c860200000006","timezone":"GMT-0400 (Eastern Da","twitter":"","pic":"","userId":"51af958f66a6f999a465f37a","phone":"","title":"","gmail":"ehl258@stern.nyu.edu","email":"ehl258@stern.nyu.edu","fullName":"Emil Lee"}]},"_id":"52a79dc7a45edbed22000018","userId":"51af958f66a6f999a465f37a","invoice":{},"profit":80}

  # 4) Michael Hue
  # TODO what is this really? doesn't look like the others.
  {"company":{"_id":"5240b80b5a0afd020000000f","name":"Clickbooq","contacts":[{"fullName":"Michael Heu","email":"mheuclickbooq@gmail.com","gmail":"mheuclickbooq@gmail.com","title":"","phone":"","userId":"5240897566a6f999a465f855","pic":"https://lh6.googleusercontent.com/-9knyZuWI_LA/AAAAAAAAAAI/AAAAAAAAACw/pmds4bFjD4Q/photo.jpg","twitter":"","timezone":"GMT-0700 (PDT)","_id":"5240ba8f5a0afd0200000012"}]},"payment":{"responseEnvelope":{"timestamp":"2013-10-30T15:32:43.762-07:00","ack":"Success","correlationId":"2d80ab74eb648","build":"7935900"},"payKey":"AP-0UY773337E442410M","paymentExecStatus":"CREATED"},"paymentType":"paypal","profit":200,"requestId":"5240ba2c5a0afd0200000011","total":600,"userId":"5240897566a6f999a465f855","paymentStatus":"received","utc":"2013-10-30T22:32:43.000Z","lineItems":[{"type":"private","total":600,"unitPrice":120,"qty":5,"suggestion":{"_id":"5241c438c20d3f020000000f","suggestedRate":{"opensource":{"expert":80,"total":100},"private":{"expert":80,"total":120},"nda":{"expert":100,"total":170}},"expert":{"_id":"5230d1a9746ee90200000018","userId":"5230d19766a6f999a465f7e0","name":"Ari Lerner","username":"auser","rate":160,"email":"writeari@gmail.com","pic":"https://lh4.googleusercontent.com/-3dziILZDWd8/AAAAAAAAAAI/AAAAAAAAAGk/o_qw9Ihr4i8/photo.jpg","paymentMethod":{"info":{"email":"arilerner@mac.com"},"type":"paypal"}}},"_id":"5271890b1c380a0200000007","qtyRedeemed":0}]}

  # 5) Order with 2 line items
  {
    "company": {"_id": "52a4ba0991935b000000002b", "contacts": [{"_id": "52a4ba0991935b000000002c", "email": "bqchristie@gmail.com", "firstName": "bruce", "fullName": "bruce christie", "gmail": "bqchristie@gmail.com", "phone": "", "pic": "https://lh6.googleusercontent.com/-Vwjei17buyc/AAAAAAAAAAI/AAAAAAAAAAA/VzQekIoMebs/photo.jpg", "timezone": "GMT-0800 (PST)", "title": "", "twitter": "", "userId": "5244496866a6f999a465f877"} ], "name": "Bruce Christie"},
    "lineItems": [
      {
        "qty": 1,
        "redeemedCalls": [],
        "suggestion": {
          "_id": "52445f41d81957020000000a",
          "expert": {
            "_id": "52372c73a9b270020000001c",
            "email": "paul@canavese.org",
            "name": "Paul Canavese",
            "paymentMethod": {
              "info": {
                "email": "consulting@canaveses.org"
              },
              "type": "paypal"
            },
            "pic": "https://secure.gravatar.com/avatar/af2766a3f9d6f81447da51e0d9af9e67",
            "rate": 70,
            "userId": "52372c3366a6f999a465f804",
            "username": "canavese"
          },
          "suggestedRate": {
            "nda": {
              "expert": 90,
              "total": 160
            },
            "opensource": {
              "expert": 70,
              "total": 90
            },
            "private": {
              "expert": 70,
              "total": 110
            }
          }
        },
        "total": 90,
        "type": "opensource",
        "unitPrice": 90
      }, {
        "qty": 1,
        "redeemedCalls": [],
        "suggestion": {
          "_id": "52445f41d81957020000000a",
          "expert": users[5],
          "suggestedRate": {
            "nda": {
              "expert": 90,
              "total": 160
            },
            "opensource": {
              "expert": 70,
              "total": 90
            },
            "private": {
              "expert": 70,
              "total": 110
            }
          }
        },
        "total": 90,
        "type": "opensource",
        "unitPrice": 90
      }
    ],
    "paymentMethod": {"info": {"account_balance": 0, "cards": {"count": 1, "data": [{"address_city": null, "address_country": null, "address_line1": null, "address_line1_check": null, "address_line2": null, "address_state": null, "address_zip": null, "address_zip_check": null, "country": "US", "customer": "cus_35N03uIhfJPhzU", "cvc_check": "pass", "exp_month": 10, "exp_year": 2014, "fingerprint": "DMfzzf5aobPBRDZg", "id": "card_35N0JRtcbhMuNs", "last4": "4242", "name": null, "object": "card", "type": "Visa"} ], "object": "list", "url": "/v1/customers/cus_35N03uIhfJPhzU/cards"}, "created": 1386527228, "default_card": "card_35N0JRtcbhMuNs", "delinquent": false, "description": null, "discount": null, "email": "bqchristie@gmail.com", "id": "cus_35N03uIhfJPhzU", "livemode": false, "object": "customer", "subscription": null }, "isPrimary": true, "type": "stripe"},
    "requestId": "52a4ba0991935b000000002d",
    "total": 180
  }

  # 6) kirk doing a 2 hour open source order
  {
    "__v" : 0,
    "_id" : ObjectId("52cd8aa33237b10200000011"),
    "company" : {
        "contacts" : [
            {
                "firstName" : "Kirk",
                "_id" : "52c85c7573abd70200000010",
                "timezone" : "GMT-0800 (PST)",
                "twitter" : "kirkstrobeck",
                "pic" : "https://lh6.googleusercontent.com/-ioZdPJuvBhM/AAAAAAAAAAI/AAAAAAAAADo/TXUziR9zSWM/photo.jpg",
                "userId" : "529e804e66a6f999a465fd15",
                "phone" : "",
                "title" : "",
                "gmail" : "kirk@strobeck.com",
                "email" : "kirk@strobeck.com",
                "fullName" : "Kirk Strobeck"
            }
        ],
        "name" : "n/a",
        "_id" : "529e96071a4bf00200000028"
    },
    "lineItems" : [
        {
            "type" : "opensource",
            "total" : 180,
            "unitPrice" : 90,
            "qty" : 2,
            "suggestion" : {
                "expert" : {
                    "paymentMethod" : {
                        "info" : {
                            "email" : "qualls.james.aws@gmail.com"
                        },
                        "type" : "paypal"
                    },
                    "pic" : "https://secure.gravatar.com/avatar/17270c1c7ec7a9b8f9e474dedbcaa5d9",
                    "email" : "qualls.james@gmail.com",
                    "rate" : 70,
                    "username" : "sourcec0de",
                    "name" : "James Qualls",
                    "userId" : "52726d0a66a6f999a465fa9d",
                    "_id" : "52726d7ef7f1d40200000015"
                },
                "suggestedRate" : {
                    "nda" : {
                        "total" : 160,
                        "expert" : 90
                    },
                    "private" : {
                        "total" : 110,
                        "expert" : 70
                    },
                    "opensource" : {
                        "total" : 90,
                        "expert" : 70
                    }
                },
                "_id" : "52cc40c71eff160200000021"
            },
            "_id" : ObjectId("52cd8aa43237b10200000012"),
            "qtyRedeemed" : 0
        }
    ],
    "payment" : {
        "dispute" : null,
        "description" : null,
        "invoice" : null,
        "customer" : "cus_3FW69dor6xqvRe",
        "amount_refunded" : 0,
        "failure_code" : null,
        "failure_message" : null,
        "balance_transaction" : "txn_3Gy3xbNjHB9MIM",
        "refunds" : [],
        "captured" : true,
        "card" : {
            "address_zip_check" : null,
            "address_line1_check" : null,
            "cvc_check" : null,
            "address_country" : null,
            "address_zip" : null,
            "address_state" : null,
            "address_city" : null,
            "address_line2" : null,
            "address_line1" : null,
            "name" : null,
            "country" : "US",
            "customer" : "cus_3FW69dor6xqvRe",
            "fingerprint" : "gmWlmcNgTSD2T6pF",
            "exp_year" : 2017,
            "exp_month" : 3,
            "type" : "American Express",
            "last4" : "4008",
            "object" : "card",
            "id" : "card_3FW69v3waX6DRE"
        },
        "refunded" : false,
        "currency" : "usd",
        "amount" : 18000,
        "paid" : true,
        "livemode" : true,
        "created" : 1389202084,
        "object" : "charge",
        "id" : "ch_3Gy3L9OIQqVzcJ"
    },
    "paymentStatus" : "paidout",
    "paymentType" : "stripe",
    "payouts" : [
        {
            "type" : "paypal",
            "status" : "success",
            "lineItemId" : ObjectId("52cd8aa43237b10200000012"),
            "req" : {
                "senderEmail" : "jk@airpair.com",
                "memo" : "https://airpair.com/review/52c86e4d73abd70200000011",
                "receiverList" : {
                    "receiver" : [
                        {
                            "amount" : "140.00",
                            "email" : "qualls.james.aws@gmail.com"
                        }
                    ]
                },
                "requestEnvelope" : {
                    "detailLevel" : "ReturnAll",
                    "errorLanguage" : "en_US"
                },
                "cancelUrl" : "https://www.airpair.com/paypal/cancel/",
                "returnUrl" : "https://www.airpair.com/paypal/success/",
                "feesPayer" : "EACHRECEIVER",
                "currencyCode" : "USD",
                "actionType" : "PAY"
            },
            "res" : {
                "sender" : {
                    "accountId" : "E496EJS2V7E6C"
                },
                "paymentInfoList" : {
                    "paymentInfo" : [
                        {
                            "senderTransactionStatus" : "COMPLETED",
                            "senderTransactionId" : "3GW71494EP766800H",
                            "pendingRefund" : "false",
                            "receiver" : {
                                "accountId" : "FQYJCJS589WQN",
                                "primary" : "false",
                                "email" : "qualls.james.aws@gmail.com",
                                "amount" : "140.00"
                            },
                            "transactionStatus" : "COMPLETED",
                            "transactionId" : "9W312459HE517835B"
                        }
                    ]
                },
                "paymentExecStatus" : "COMPLETED",
                "payKey" : "AP-3RA29924L91098603",
                "responseEnvelope" : {
                    "build" : "7935900",
                    "correlationId" : "b591bd757939c",
                    "ack" : "Success",
                    "timestamp" : "2014-01-09T09:34:15.927-08:00"
                }
            },
            "_id" : ObjectId("52cedd97da510a0200000020")
        }
    ],
    "profit" : 40,
    "requestId" : ObjectId("52c86e4d73abd70200000011"),
    "total" : 180,
    "userId" : ObjectId("529e804e66a6f999a465fd15"),
    "utc" : ISODate("2014-01-08T17:28:04.000Z"),
    "utm" : {
        "utm_campaign" : "so3",
        "utm_content" : "better",
        "utm_term" : "angularjs",
        "utm_medium" : "banner",
        "utm_source" : "stackoverflow"
    }
  }

  # 7 kirk doing a 5 hour private session
  {
    "company" : {
        "contacts" : [
            {
                "firstName" : "Kirk",
                "_id" : "52c85c7573abd70200000010",
                "timezone" : "GMT-0800 (PST)",
                "twitter" : "kirkstrobeck",
                "pic" : "https://lh6.googleusercontent.com/-ioZdPJuvBhM/AAAAAAAAAAI/AAAAAAAAADo/TXUziR9zSWM/photo.jpg",
                "userId" : "529e804e66a6f999a465fd15",
                "phone" : "",
                "title" : "",
                "gmail" : "kirk@strobeck.com",
                "email" : "kirk@strobeck.com",
                "fullName" : "Kirk Strobeck"
            }
        ],
        "name" : "n/a",
        "_id" : "529e96071a4bf00200000028"
    },
    "lineItems" : [
        {
            "type" : "private",
            "total" : 550,
            "unitPrice" : 110,
            "qty" : 5,
            "suggestion" : {
                "expert" : {
                    "paymentMethod" : {
                        "type" : "paypal",
                        "info" : {
                            "email" : "qualls.james.aws@gmail.com"
                        }
                    },
                    "pic" : "https://secure.gravatar.com/avatar/17270c1c7ec7a9b8f9e474dedbcaa5d9",
                    "email" : "qualls.james@gmail.com",
                    "rate" : 70,
                    "username" : "sourcec0de",
                    "name" : "James Qualls",
                    "userId" : "52726d0a66a6f999a465fa9d",
                    "_id" : "52726d7ef7f1d40200000015"
                },
                "suggestedRate" : {
                    "nda" : {
                        "total" : 160,
                        "expert" : 90
                    },
                    "private" : {
                        "total" : 110,
                        "expert" : 70
                    },
                    "opensource" : {
                        "total" : 90,
                        "expert" : 70
                    }
                },
                "_id" : "52cc40c71eff160200000021"
            },
            "_id" : ObjectId("52cc45bd1eff160200000023"),
            "redeemedCalls" : []
        }
    ],
    "payment" : {
        "dispute" : null,
        "description" : null,
        "invoice" : null,
        "customer" : "cus_3FW69dor6xqvRe",
        "amount_refunded" : 0,
        "failure_code" : null,
        "failure_message" : null,
        "balance_transaction" : "txn_3GbhJ0mVoUWZGM",
        "refunds" : [],
        "captured" : true,
        "card" : {
            "address_zip_check" : null,
            "address_line1_check" : null,
            "cvc_check" : null,
            "address_country" : null,
            "address_zip" : null,
            "address_state" : null,
            "address_city" : null,
            "address_line2" : null,
            "address_line1" : null,
            "name" : null,
            "country" : "US",
            "customer" : "cus_3FW69dor6xqvRe",
            "fingerprint" : "gmWlmcNgTSD2T6pF",
            "exp_year" : 2017,
            "exp_month" : 3,
            "type" : "American Express",
            "last4" : "4008",
            "object" : "card",
            "id" : "card_3FW69v3waX6DRE"
        },
        "refunded" : false,
        "currency" : "usd",
        "amount" : 55000,
        "paid" : true,
        "livemode" : true,
        "created" : 1389118908,
        "object" : "charge",
        "id" : "ch_3GbhttRUFtmKbx"
    },
    "paymentStatus" : "paidout",
    "paymentType" : "stripe",
    "payouts" : [
        {
            "type" : "paypal",
            "status" : "success",
            "lineItemId" : ObjectId("52cc45bd1eff160200000023"),
            "req" : {
                "senderEmail" : "jk@airpair.com",
                "memo" : "https://airpair.com/review/52c86e4d73abd70200000011",
                "receiverList" : {
                    "receiver" : [
                        {
                            "amount" : "350.00",
                            "email" : "qualls.james.aws@gmail.com"
                        }
                    ]
                },
                "requestEnvelope" : {
                    "detailLevel" : "ReturnAll",
                    "errorLanguage" : "en_US"
                },
                "cancelUrl" : "https://www.airpair.com/paypal/cancel/",
                "returnUrl" : "https://www.airpair.com/paypal/success/",
                "feesPayer" : "EACHRECEIVER",
                "currencyCode" : "USD",
                "actionType" : "PAY"
            },
            "res" : {
                "sender" : {
                    "accountId" : "E496EJS2V7E6C"
                },
                "paymentInfoList" : {
                    "paymentInfo" : [
                        {
                            "senderTransactionStatus" : "COMPLETED",
                            "senderTransactionId" : "71721992CU9941147",
                            "pendingRefund" : "false",
                            "receiver" : {
                                "accountId" : "FQYJCJS589WQN",
                                "primary" : "false",
                                "email" : "qualls.james.aws@gmail.com",
                                "amount" : "350.00"
                            },
                            "transactionStatus" : "COMPLETED",
                            "transactionId" : "9TP817278P372054E"
                        }
                    ]
                },
                "paymentExecStatus" : "COMPLETED",
                "payKey" : "AP-3FN06579B1348360R",
                "responseEnvelope" : {
                    "build" : "7935900",
                    "correlationId" : "7fa9222676198",
                    "ack" : "Success",
                    "timestamp" : "2014-01-09T09:34:10.417-08:00"
                }
            },
            "_id" : ObjectId("52cedd92751ae70200000016")
        }
    ],
    "profit" : 200,
    "requestId" : ObjectId("52c86e4d73abd70200000011"),
    "total" : 550,
    "userId" : ObjectId("529e804e66a6f999a465fd15"),
    "utc" : ISODate("2014-01-07T18:21:49.000Z"),
    "utm" : {
        "utm_campaign" : "so3",
        "utm_content" : "better",
        "utm_term" : "angularjs",
        "utm_medium" : "banner",
        "utm_source" : "stackoverflow"
    }
  }

  # 8) tinfow / imageplant booking [ 2hr private domenic, 5hr private domenic, 5hr private domenic ]
  [{"__v":0,"_id":"52cc60bd1eff16020000002a","company":{"_id":"52cc156b1b80d70200000017","name":"IMAGE PLANT","contacts":[{"fullName":"Randall Tinfow","email":"tinfow@imageplant.net","gmail":"tinfow@imageplant.net","title":"","phone":"973-202-2028","userId":"52cc074266a6f999a465fed3","pic":"","twitter":"rtinfow","timezone":"GMT-0500 (EST)","_id":"52cc156b1b80d70200000018","firstName":"Randall"}]},"payment":{"payout":{"paymentExecStatus":"COMPLETED","responseEnvelope":{"build":"7935900","correlationId":"ed2a16bf4e5f4","ack":"Success","timestamp":"2014-01-09T08:36:44.206-08:00"}},"responseEnvelope":{"timestamp":"2014-01-07T12:17:02.426-08:00","ack":"Success","correlationId":"311db085c0dde","build":"7935900"},"payKey":"AP-4VC99978MP9334007","paymentExecStatus":"CREATED"},"paymentType":"paypal","profit":80,"requestId":"52cc17221eff160200000016","total":300,"userId":"52cc074266a6f999a465fed3","marketingTags":[{"_id":"52d8e8af8d1b07020000001b","name":"search","type":"channel","group":"seo"}],"owner":"mi","paymentStatus":"paidout","payouts":[],"utc":"2014-01-07T20:17:02.000Z","lineItems":[{"type":"private","total":300,"unitPrice":150,"qty":2,"suggestion":{"_id":"52cc45b11b80d70200000032","suggestedRate":{"opensource":{"expert":110,"total":130},"private":{"expert":110,"total":150},"nda":{"expert":130,"total":200}},"expert":{"_id":"5296c8964546790200000032","userId":"5296c85d66a6f999a465fca4","name":"Domenic Denicola","username":"domenic","rate":110,"email":"domenic@domenicdenicola.com","pic":"https://secure.gravatar.com/avatar/c6d819207a3010b39d13e1f59f2c0029","paymentMethod":{"type":"paypal","info":{"email":"domenic@domenicdenicola.com"}}}},"_id":"52cc60be1eff16020000002b","redeemedCalls":[{"callId":"52e5c58c7b433e0200000009","qtyRedeemed":2,"_id":"52e5c58e7b433e020000000a","qtyCompleted":0}]}]},{"__v":0,"_id":"52ce9cddda510a020000001c","company":{"_id":"52cc156b1b80d70200000017","name":"IMAGE PLANT","contacts":[{"fullName":"Randall Tinfow","email":"tinfow@imageplant.net","gmail":"tinfow@imageplant.net","title":"","phone":"973-202-2028","userId":"52cc074266a6f999a465fed3","pic":"","twitter":"rtinfow","timezone":"GMT-0500 (EST)","_id":"52cc156b1b80d70200000018","firstName":"Randall"}]},"payment":{"payout":{"paymentExecStatus":"COMPLETED","responseEnvelope":{"build":"7935900","correlationId":"c18eae0a56451","ack":"Success","timestamp":"2014-01-30T14:47:33.595-08:00"}},"responseEnvelope":{"timestamp":"2014-01-09T04:58:06.093-08:00","ack":"Success","correlationId":"a36e0b6029ebf","build":"7935900"},"payKey":"AP-37P00136B46307350","paymentExecStatus":"CREATED"},"paymentType":"paypal","profit":200,"requestId":"52cc17221eff160200000016","total":750,"userId":"52cc074266a6f999a465fed3","marketingTags":[{"_id":"52d8e8af8d1b07020000001b","name":"search","type":"channel","group":"seo"}],"owner":"mi","paymentStatus":"paidout","payouts":[],"utc":"2014-01-09T12:58:06.000Z","lineItems":[{"type":"private","total":750,"unitPrice":150,"qty":5,"suggestion":{"_id":"52cc45b11b80d70200000032","suggestedRate":{"opensource":{"expert":110,"total":130},"private":{"expert":110,"total":150},"nda":{"expert":130,"total":200}},"expert":{"_id":"5296c8964546790200000032","userId":"5296c85d66a6f999a465fca4","name":"Domenic Denicola","username":"domenic","rate":110,"email":"domenic@domenicdenicola.com","pic":"https://secure.gravatar.com/avatar/c6d819207a3010b39d13e1f59f2c0029","paymentMethod":{"info":{"email":"domenic@domenicdenicola.com"},"type":"paypal"}}},"_id":"52ce9cdeda510a020000001d","qtyRedeemed":0,"redeemedCalls":[]}]},{"__v":0,"_id":"52d6e2671b8a310200000023","company":{"_id":"52cc156b1b80d70200000017","name":"IMAGE PLANT","contacts":[{"fullName":"Randall Tinfow","email":"tinfow@imageplant.net","gmail":"tinfow@imageplant.net","title":"","phone":"973-202-2028","userId":"52cc074266a6f999a465fed3","pic":"","twitter":"rtinfow","timezone":"GMT-0500 (EST)","_id":"52cc156b1b80d70200000018","firstName":"Randall"}]},"payment":{"responseEnvelope":{"timestamp":"2014-01-15T11:32:56.708-08:00","ack":"Success","correlationId":"7aa00baee2356","build":"7935900"},"payKey":"AP-4GX704885Y916783Y","paymentExecStatus":"CREATED"},"paymentType":"paypal","profit":200,"requestId":"52cc17221eff160200000016","total":750,"userId":"52cc074266a6f999a465fed3","marketingTags":[{"_id":"52d8e8af8d1b07020000001b","name":"search","type":"channel","group":"seo"}],"owner":"mi","paymentStatus":"received","payouts":[],"utc":"2014-01-15T19:32:56.000Z","lineItems":[{"type":"private","total":750,"unitPrice":150,"qty":5,"suggestion":{"_id":"52cc45b11b80d70200000032","suggestedRate":{"opensource":{"expert":110,"total":130},"private":{"expert":110,"total":150},"nda":{"expert":130,"total":200}},"expert":{"_id":"5296c8964546790200000032","userId":"5296c85d66a6f999a465fca4","name":"Domenic Denicola","username":"domenic","rate":110,"email":"domenic@domenicdenicola.com","pic":"https://secure.gravatar.com/avatar/c6d819207a3010b39d13e1f59f2c0029","paymentMethod":{"type":"paypal","info":{"email":"domenic@domenicdenicola.com"}}}},"_id":"52d6e2681b8a310200000024","qtyRedeemed":0,"redeemedCalls":[]}]}]
]
