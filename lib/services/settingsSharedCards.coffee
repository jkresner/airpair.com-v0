SettingsService  = require './settings'

test = {
  "type": "stripe",
  "info": {
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
    "object": "customer",
    sharers: []
  },
  "isPrimary": false,
  "_id": "52a7911918bc8ee967000006",
}

module.exports = class SharedCardsService extends SettingsService

  user: require './../models/user'

  teamAirpairSettingsId: '52a65d142320fe0200000006'

  # Here we used the settings of the team@airpair.com account to host
  # our shared cards (TOTAL HACK to not alter our mongoose model)
  getSharedCards: (callback) =>
    # pm = [test]
    # @_updPM @teamAirpairSettingsId, pm, =>
    @model.findOne({ _id: @teamAirpairSettingsId }).lean().exec (e, r) =>
      callback e, r

  addCard: (d, email, callback) =>
    {token} = d.stripeCreate
    delete d.stripeCreate

    stripeSvc.createCustomer email, token, (e, customer) =>
      if e then return callback e
      if customer?
        customer.sharers = []
        d.paymentMethods.push { type: 'stripe', info: customer }
      callback null


  removeCard: (id, callback) =>
    throw new Error "Remove Card not yet implemented"
    # @getSharedCards (r) =>
    #   card = _.find r.paymentMethods, (c) -> c._id == id
    #   if !card? throw new Error 'No card with id #{id} to remove'
    #   paymentMethods = _.without r.paymentMethods, card
    #   @model.findOneAndUpdate({_id:r._id}, {paymentMethods}).lean().exec (e, rr) =>
    #     callback e, rr


  shareCard: (id, email, callback) =>
    @_getStuff id, email, (usr, usrSettings, shared, card) =>
      # $log 'CARD.sharers', card.info.sharers
      # $log 'usrSettings', usrSettings

      for s in card.info.sharers
        if s? then return callback "Already shared card with #{email}"

      # make sure we only have one stripe customer settings
      existingStripe = _.findWhere usrSettings.paymentMethods, {type: 'stripe'}
      uPayMethods = _.without usrSettings.paymentMethods, existingStripe

      # we don't want to store sharers in each sharer's settings
      uPayMethods.push { type: 'stripe', info: _.omit(card.info, 'sharers') }

      @_updPM usrSettings._id, uPayMethods, (e) =>
        if e? then return callback e
        card.info.sharers.push { userId: usr._id, settingsId: usrSettings._id, email }
        @_updPM shared._id, shared.paymentMethods, callback


  unshareCard: (id, email, callback) =>
    @getByUserId usr._id, (e, d) =>
      if !d.paymentMethods? then throw new Error "Cannot unshare card when settings for user #{user.email} don't exits"
      @getSharedCards (r) =>
        card = @getCard id
        sharer = _.find card.info.sharers, (s) -> _.idsEqual s.userId, usr._id
        if !sharer? then throw new Error "Cannot unshare card for #{usr.email}"
        card.info.sharers = _.without card.info.sharers, sharer
        $log 'unshareCard.paymentMethods', r.paymentMethods, id, usr
        @_updPM r._id, r.paymentMethods, (e) -> if e? then callback e
        @_updPM d._id, d.paymentMethods, callback


  # update the payment Methods for both the user and the shared cards
  _updPM: (_id, paymentMethods, callback) =>
    @model.findOneAndUpdate({_id}, {paymentMethods}).lean().exec (e, r) =>
      if e? then return callback e
      if callback? then callback e, r


  _getStuff: (cardId, email, callback) =>
    @user.findOne { 'google._json.email': email }, (e, user) =>
      if !user? || !user.google? then return callback new Error "User not found for #{email}"
      @getByUserId user._id, (ee, settings) =>
        getCards = => @getSharedCards (eee, cards) =>
          card = _.find cards.paymentMethods, (c) -> _.idsEqual c._id, cardId
          callback user, settings, cards, card

        if settings._id? then getCards() else @create user._id, null, getCards

  # getCard: (settings, cardId) =>
  #   if !card? then throw new Error 'No card with id #{id}'
  #   card
