DomainService   = require './_svc'
SettingsService = require './settings'
StripeService   = require './payment/stripe'


module.exports = class PayMethodsService extends DomainService

  user: require './../models/user'
  model: require './../models/payMethod'

  settingsSvc: new SettingsService()
  stripeSvc = new StripeService()

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
    @getById id, (e, payMethod) =>
      if e? then return callback e
      if payMethod.sharers.length == 0
        @model.findByIdAndRemove id, callback
      else
        i = 0
        sharesLength = payMethod.sharers.length
        for s in payMethod.sharers
          $log 'unsharing payMethod', s.email
          @unshare id, s.email, =>
            i++
            if i == sharesLength
              $log 'deleting shared payMethod'
              @model.findByIdAndRemove id, callback

  #TODO setPeopleProps paymentInfoSet: 'stripe'
  share: (id, email, callback) =>
    @_getObjs id, email, (usr, settings, payMethod) =>
      sharer = _.find payMethod.sharers, (s) -> _.idsEqual s.userId, usr._id
      if sharer? then return callback new Error "Already shared w #{email}"

      @settingsSvc.addStripeSettings payMethod.info, settings, (e,r) =>
        if e? then return callback e
        payMethod.sharers.push userId: usr._id, settingsId: settings._id, email: email
        @update payMethod._id, { sharers: payMethod.sharers }, callback

  #TODO un-setPeopleProps paymentInfoSet: 'stripe'
  unshare: (id, email, callback) =>
    @_getObjs id, email, (usr, settings, payMethod) =>
      sharer = _.find payMethod.sharers, (s) -> _.idsEqual s.userId, usr._id
      if !sharer then return callback new Error "#{email} not a payMethod sharer"

      pm = _.find settings.paymentMethods, (p) -> p.info.id == payMethod.info.id
      settings.paymentMethods = _.without settings.paymentMethods, pm

      @settingsSvc.update settings, (e) =>
        if e? then return callback e
        payMethod.sharers = _.without payMethod.sharers, sharer
        @update payMethod._id, { sharers: payMethod.sharers }, callback


  _getObjs: (id, email, callback) =>
    @user.findOne { 'google._json.email': email }, (e, usr) =>
      if !usr? || !usr.google? then return callback new Error "User #{email} not found"
      @settingsSvc.getByUserId usr._id, (ee, settings) =>
        getPayMethod = (err, stgs) => @getById id, (eee, pm) =>
          callback usr, stgs, pm

        if settings._id?
          getPayMethod null, settings
        else
          @settingsSvc.create usr._id, null, getPayMethod


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
