DomainService = require './_svc'
SettingsService  = require './settings'

testStripeCustomer =
  "default_card": "card_36B3Sti9FDKquN",
  "cards": {
    "data": [
      {
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
        "customer": "cus_36B3nJyo2mKv0m",
        "fingerprint": "DMfzzf5aobPBRDZg",
        "exp_year": 2016,
        "exp_month": 12,
        "type": "Visa",
        "last4": "4242",
        "object": "card",
        "id": "card_36B3Sti9FDKquN"
      }
    ],
    "url": "/v1/customers/cus_36B3nJyo2mKv0m/cards",
    "count": 1,
    "object": "list"
  },
  "account_balance": 0,
  "discount": null,
  "subscription": null,
  "delinquent": false,
  "email": "jk@airpair.com",
  "description": null,
  "livemode": false,
  "id": "cus_36B3nJyo2mKv0m",
  "created": 1386713369,
  "object": "customer"


module.exports = class PayMethodsService extends DomainService

  user: require './../models/user'
  model: require './../models/payMethod'

  settingsSvc: new SettingsService()


  seed: (cb) =>
    $log 'seeding'
    new @model( sharers: [], type: 'stripe', info: testStripeCustomer ).save cb


  create: (token, email, callback) =>
    stripeSvc.createCustomer email, token, (e, customer) =>
      if e then return callback e
      if customer?
        o = sharers: [], type: 'stripe', info: customer
        new @model( o ).save callback


  delete: (id, callback) =>
    throw new Error "Delete payMethod not yet implemented"
    # @getSharedCards (r) =>
    #   card = _.find r.paymentMethods, (c) -> c._id == id
    #   if !card? throw new Error 'No card with id #{id} to remove'
    #   paymentMethods = _.without r.paymentMethods, card
    #   @model.findOneAndUpdate({_id:r._id}, {paymentMethods}).lean().exec (e, rr) =>
    #     callback e, rr


  share: (id, email, callback) =>
    @_getObjs id, email, (usr, settings, payMethod) =>
      for s in payMethod.sharers
        if s.userId is usr._id then return callback "Already shared w #{email}"

      @settingsSvc.addStripeSettings payMethod.info, settings, (e,r) =>
        if e? then return callback e
        payMethod.sharers.push userId: usr._id, settingsId: settings._id, email: email
        @update payMethod._id, { sharers: payMethod.sharers }, callback


  unshare: (id, email, callback) =>
    @_getObjs id, email, (usr, settings, payMethod) =>
      sharer = _.find payMethod.sharers, (s) -> _.idsEqual s.userId, usr._id
      if !sharer? then throw new Error "#{email} not a payMethod sharer"

      pm = _.findWhere settings.paymentMethods, { 'info._id': id }
      settings.paymentMethods = _.without settings.paymentMethods, pm

      @settingsSvc.update settings, (e) =>
        if e? then return callback e
        payMethod.sharers = _.without payMethod.sharers, sharer
        $log 'payMethod.sharers', payMethod.sharers
        @update payMethod._id, { sharers: payMethod.sharers }, callback


  _getObjs: (id, email, callback) =>
    @user.findOne { 'google._json.email': email }, (e, usr) =>
      if !usr? || !usr.google? then return callback new Error "User #{email} not found"
      @settingsSvc.getByUserId usr._id, (ee, settings) =>
        getPayMethod = => @getById id, (eee, pm) =>
          callback usr, settings, pm

        if settings._id?
          getPayMethod()
        else
          @settingsSvc.create user._id, null, getPayMethod
