DomainService  = require './_svc'
StripeService  = require './payment/stripe'
stripeSvc = new StripeService()

module.exports = class SettingsService extends DomainService

  model: require './../models/settings'

  getByUserId: (userId, callback) =>
    @model.findOne({ userId: userId }).lean().exec (e, r) =>
      # $log 'settings getByUserId', userId
      if e then return callback e
      if ! r? then r = {}
      callback null, r


  create: (userId, data, callback) =>
    data.userId = userId.toString()
    save = =>
      new @model( data ).save (e, r) =>
        # $log '@model.save', e, r
        callback e, r
    if data.stripeCreate? then @addStripeCustomerSettings(data, save) else save()


  update: (userId, data, callback) =>
    ups = _.clone data
    # ups.paymentMethods = settings.paymentMethods
    ups.userId = userId
    delete ups._id
    # (JK 2013.10.15) very sorry I know this is bad code ...
    save = () =>
      @model.findOneAndUpdate({userId:userId}, ups, { upsert: true }).lean().exec (e, r) =>
        # $log 'save.settings', e, r
        callback e, r

    if data.stripeCreate? then @addStripeCustomerSettings(ups, save) else save()


  addStripeCustomerSettings: (d, callback) =>
    {email,token} = d.stripeCreate
    delete d.stripeCreate

    # make sure we only have one stripe customer settings
    d.paymentMethods = _.without d.paymentMethods, _.findWhere(d.paymentMethods, {type: 'stripe'})

    stripeSvc.createCustomer email, token, (e, customer) =>
      if e then return callback e
      if customer?
        isPrimary = d.paymentMethods.length == 0
        d.paymentMethods.push { type: 'stripe', info: customer, isPrimary: isPrimary }
      callback null


  getStripeCustomerId: (settings) =>
    for method in settings.paymentMethods
      if method.type is 'stripe'
        if method.customerId? then return method.customerId
    'null'
