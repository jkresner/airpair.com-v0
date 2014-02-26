util             = require './../../app/scripts/util'
async            = require 'async'
RequestsSvc      = require './../services/requests'
ExpertsSvc       = require './../services/experts'
TagsSvc          = require './../services/tags'
OrdersSvc        = require './../services/orders'
SettingsSvc      = require './../services/settings'
RequestCallsSvc  = require './../services/requestCalls'

rSvc  = new RequestsSvc()
eSvc  = new ExpertsSvc()
tSvc  = new TagsSvc()
oSvc  = new OrdersSvc()
sSvc  = new SettingsSvc()
rcSvc = new RequestCallsSvc()

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

  settings: (usr, callback) ->
    callback null,
      stripePK: cfg.payment.stripe.publishedKey

  stripeCheckout: (usr, order, callback) ->
    {qty,unitPrice} = order
    total = qty * unitPrice
    pk = global.cfg.payment.stripe.publishedKey
    sSvc.getByUserId usr._id, (e, r) =>
      if e then return callback e
      callback null, _.extend {total,qty,unitPrice,pk},
        session:    @session usr
        customerId: JSON.stringify r

  review: (usr, id, callback) ->
    rSvc.getByIdSmart id, usr, (e, r) =>
      if e then return callback e
      callback null,
        isProd:     cfg.isProd.toString()
        session:    @session usr
        request:    JSON.stringify r
        tagsString: if r? then util.tagsString(r.tags) else 'Not found'

  calls: (usr, callId, answer, callback) ->
    usr._id = "51a6167218dd8a0200000005" # edward anderson
    # get all calls for an expert
    serveCalls = =>
      rcSvc.getByExpertId usr._id, (err, calls) =>
        callback null, calls: JSON.stringify calls

    if !callId || !answer
      callback = callId
      return serveCalls()

    answer2status = 'yes': 'confirmed', 'no': 'declined'
    status = answer2status[answer]
    if !status then return serveCalls()
    rcSvc.rsvp usr, callId, status, (err) =>
      if err then return callback err
      serveCalls()

  # used for both customer and admin versions
  # TODO dont send down sensitive data
  callSchedule: (usr, requestId, callback) ->
    tasks =
      request: (cb) -> rSvc.getById requestId, cb
      orders: (cb) -> oSvc.getByRequestId requestId, cb

    async.parallel tasks, (e, results) =>
      if e then return callback e
      callback null,
        request: JSON.stringify results.request
        orders: JSON.stringify results.orders

  callEdit: (usr, callId, callback) ->
    rSvc.getByCallId callId, (e, request) ->
      if e then return callback e
      oSvc.getByRequestId request._id, (e, orders) ->
        if e then return callback e
        callback null,
          request: JSON.stringify request
          orders: JSON.stringify orders

  book: (usr, id, callback) ->
    eSvc.getByBookme id, (e, r) =>
      if e then return callback e
      callback null,
        isAnonymous:  !usr?
        session:      @session usr
        expert:       r
        expertStr:    JSON.stringify r

  inbound: (usr, callback) ->
    rSvc.getActive (err, requests) =>
      if err then return callback err
      callback null,
        session: @session usr
        requests: JSON.stringify(requests)


  companys: (usr, callback) ->
    eSvc.getAll (e, r) =>
      callback null,
        session: @session usr
        experts: JSON.stringify r
        stripePK: cfg.payment.stripe.publishedKey

  experts: (usr, callback) ->
    eSvc.getAll (e, r) =>
      callback null,
        session: @session usr
        experts: JSON.stringify r

  stripeCharge: (usr, orderId, token, callback) ->
    oSvc.markPaymentReceived orderId, usr, {}, (e, o) =>
      if e then return callback e
      callback null,
        session: @session usr
        order: JSON.stringify null, o
        stripePK: cfg.payment.stripe.publishedKey

  paypalSuccess: (usr, orderId, callback) ->
    oSvc.markPaymentReceived orderId, usr, {}, (e, o) =>
      if e then return callback e
      callback null,
        session: @session usr
        order: JSON.stringify o

  paypalCancel: (usr, orderId, callback) ->
    oSvc.getById orderId, (e, o) =>
      if e then return callback e
      callback null,
        session: @session usr
        order: JSON.stringify o
