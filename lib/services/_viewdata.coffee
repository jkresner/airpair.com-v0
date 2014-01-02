util = require './../../app/scripts/util'
async = require 'async'
RequestsSvc = require './../services/requests'
ExpertsSvc = require './../services/experts'
TagsSvc = require './../services/tags'
OrdersSvc = require './../services/orders'
SettingsSvc = require './../services/settings'
rSvc = new RequestsSvc()
eSvc = new ExpertsSvc()
tSvc = new TagsSvc()
oSvc = new OrdersSvc()
sSvc = new SettingsSvc()

module.exports = class ViewDataService

  session: (user) ->
    if user? && user.google?
      # the tests pass in a plain object
      u = (user.toObject && user.toObject()) || user
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

  book: (id, usr, callback) ->
    eSvc.getById id, (e, r) =>
      if e then return callback e
      callback null,
        session:    @session usr
        expert:     JSON.stringify r
        expertName: r.name

  inbound: (usr, callback) ->
    fns =
      tags: (cb) ->
        tSvc.getAll cb
      experts: (cb) ->
        eSvc.getAll cb
      requests: (cb) ->
        rSvc.getActive cb

    async.parallel fns, (e, results) =>
      if e then return callback e
      callback null,
        session:  @session usr
        requests: JSON.stringify results.requests
        experts:  JSON.stringify results.experts
        tags:     JSON.stringify results.tags

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
