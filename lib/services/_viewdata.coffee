util = require './../../app/scripts/util'
async = require 'async'
RequestsSvc = require './../services/requests'
ExpertsSvc = require './../services/experts'
TagsSvc = require './../services/tags'
MarketingTagsSvc = require './../services/marketingtags'
OrdersSvc = require './../services/orders'
SettingsSvc = require './../services/settings'
rSvc = new RequestsSvc()
eSvc = new ExpertsSvc()
tSvc = new TagsSvc()
mtSvc = new MarketingTagsSvc()
oSvc = new OrdersSvc()
sSvc = new SettingsSvc()

module.exports = class ViewDataService

  session: (user) ->
    if user? && user.google?
      u = _.clone user
      if u.google then delete u.google.token
      if u.twitter then delete u.twitter.token
      if u.bitbucket then delete u.bitbucket.token
      if u.github then delete u.github.token
      if u.stack then delete u.stack.token
    else
      u = authenticated : false

    JSON.stringify u

  stripeCheckout: (usr, order, callback) ->
    {qty,unitPrice} = order
    total = qty * unitPrice
    pk = global.cfg.payment.stripe.publishedKey
    sSvc.getByUserId usr._id, (e, r) =>
      if e then return callback e
      callback null, _.extend {total,qty,unitPrice,pk},
        session:    @session usr
        customerId: JSON.stringify r

  review: (id, usr, callback) ->
    rSvc.getByIdSmart id, usr, (e, r) =>
      if e then return callback e
      callback null,
        isProd:     cfg.isProd.toString()
        session:    @session usr
        request:    JSON.stringify r
        tagsString: if r? then util.tagsString(r.tags) else 'Not found'

  schedule: (requestId, callback) ->
    tasks =
      request: (cb) -> rSvc.getById requestId, cb
      orders: (cb) -> oSvc.getByRequestId requestId, cb

    async.parallel tasks, (e, results) =>
      if e then return callback e
      callback null,
        request: JSON.stringify results.request
        orders: JSON.stringify results.orders

  book: (id, usr, callback) ->
    eSvc.getById id, (e, r) =>
      if e then return callback e
      callback null,
        session:    @session usr
        expert:     JSON.stringify r
        expertName: r.name

  inbound: (usr, callback) ->
    callback null, session: @session usr

  landingTag: (tagSearchTerm, usr, callback) ->
    tSvc.search tagSearchTerm, (e, o) =>
      if e then return callback e
      vd =
        session: @session usr
        tag:     o
      if o?
        vd.tag.img = o.soId
        if o.soId[0] is '.' then vd.tag.img = o.soId.substring(1) # for '.net'
        vd.tag.lowercase_name = vd.tag.name.toLowerCase()
        vd.tag.lowercase_short = vd.tag.short.toLowerCase()
        tSvc.cms o._id, (e, c) =>
          if e then return callback e
          vd.tagCms = if c? then c else {}
          callback null, vd
      else
        callback null, vd

  stripeCharge: (orderId, usr, token, callback) ->
    # oSvc.markPaymentReceived orderId, usr, {}, (o) => callback
    oSvc.markPaymentReceived orderId, usr, {}, (e, o) =>
      if e then return callback e
      callback null,
        session: @session usr
        order: JSON.stringify null, o

  paypalSuccess: (orderId, usr, callback) ->
    oSvc.markPaymentReceived orderId, usr, {}, (e, o) =>
      if e then return callback e
      callback null,
        session: @session usr
        order: JSON.stringify o

  paypalCancel: (orderId, usr, callback) ->
    oSvc.getById orderId, (e, o) =>
      if e then return callback e
      callback null,
        session: @session usr
        order: JSON.stringify o
