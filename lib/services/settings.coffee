DomainService = require './_svc'
StripeService = require './payment/stripe'
stripeSvc = new StripeService()

module.exports = class SettingsService extends DomainService

  model: require './../models/settings'


  getByUserId: (userId, callback) =>
    @searchOne { userId }, callback


  _save: (data, callback) =>
    ups = _.omit data, '_id'
    {userId} = ups
    @model.findOneAndUpdate({userId}, ups, { upsert: true }).lean().exec (e, r) =>
      callback e, r


  create: (userId, d, cb) =>
    if !d? then d = paymentMethods: []
    d.userId = userId.toString()
    if d.stripeCreate? then @createStripeSettings(d,cb) else @_save(d, cb)


  update: (d, cb) =>
    $log 'settings,updating', d?, cb
    if d.stripeCreate? then @createStripeSettings(d,cb) else @_save(d, cb)


  addPayPalSettings: (userId, email, cb) =>
    @getByUserId userId, (e, settings) =>
      paypal = type: 'paypal', isPrimary: true, info: { email }
      if !settings? || !settings._id?
        @create userId, { paymentMethods: [paypal] }, cb
      else
        existing = _.findWhere settings.paymentMethods, { type: 'paypal' }
        if !existing?
          settings.paymentMethods.push paypal
        else if existing.info.email != email
          existing.info.email = email

        @update settings, cb


  createStripeSettings: (d,cb) =>
    {email,token} = d.stripeCreate
    delete d.stripeCreate

    stripeSvc.createCustomer email, token, (e, customer) =>
      if e then return callback e
      @addStripeSettings customer, d, cb


  addStripeSettings: (customer, settings, callback) =>
    d = settings
    isPrimary = d.paymentMethods.length == 0

    # make sure we only have one stripe customer settings
    existingStripe = _.findWhere d.paymentMethods, { type: 'stripe' }
    d.paymentMethods = _.without d.paymentMethods, existingStripe

    d.paymentMethods.push type: 'stripe', info: customer, isPrimary: isPrimary

    @_save d, callback


  getStripeCustomerId: (settings) =>
    for method in settings.paymentMethods
      if method.type is 'stripe'
        if method.customerId? then return method.customerId
    'null'
