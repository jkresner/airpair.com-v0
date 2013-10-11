DomainService  = require './_svc'
StripeService  = require './payment/stripe'
# stripeSvc = new StripeService()

module.exports = class SettingsService extends DomainService

  model: require './../models/settings'

  getByUserId: (userId, callback) =>
    @model.findOne({ userId: userId }).lean().exec (e, r) =>
      if ! r? then r = {}
      callback r


  create: (userId, o, callback) =>
    o.userId = userId.toString()
    new @model( o ).save (e, r) => callback r


  update: (userId, data, callback) =>
    ups = _.clone data
    data.userId = userId
    delete ups._id
    @model.findOneAndUpdate({userId:userId}, ups, { upsert: true }).lean().exec (e, r) =>
      # $log 'save.settings', e, r
      callback r


  addStripeCustomerId: (usr, token, callback) =>
    $log 'addStripeCustomerId', usr, token
    @getByUserId usr._id, (r) =>
      stripeSvc.createCustomer usr.google._json.email, token, (customer) =>
        $log 'customer', customer
        r.paymentMethods.push { type: 'stripe', customerId: customer.id }
        @update usr._id, r, (rr) => callback rr

  getStripeCustomerId: (settings) =>
    for method in settings.paymentMethods
      if method.type is 'stripe'
        if method.customerId? then return method.customerId
    'null'