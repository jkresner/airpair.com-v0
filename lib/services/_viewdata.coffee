async            = require 'async'
TagsSvc          = require '../services/tags'
OrdersSvc        = require '../services/orders'
ExpertsSvc       = require '../services/experts'
CompanysSvc      = require '../services/companys'
SettingsSvc      = require '../services/settings'
RequestsSvc      = require '../services/requests'
RequestCallsSvc  = require '../services/requestCalls'
stripePK         = cfg.payment.stripe.publishedKey

module.exports = class ViewDataService

  logging: off

  constructor: (user) ->
    @usr = user

  # session gets called from viewRender.render
  session: (full) ->
    if @usr? && @usr.google?
      u = _.clone @usr
      if u.google then delete u.google.token
      if u.twitter then delete u.twitter.token
      if u.bitbucket then delete u.bitbucket.token
      if u.github then delete u.github.token
      if u.stack then delete u.stack.token
      u.authenticated = true
      if full
        u
      else
        _.pick u, ['_id','google','googleId']
    else
      authenticated : false

  review: (id, cb) ->
    new RequestsSvc(@usr).getByIdSmart id, (e, request) =>
      cb e, -> { request }


  settings: (callback) ->
    callback null, { stripePK }



  callSchedule: (requestId, callback) ->
    rSvc.getById requestId, (e, request) =>
      oSvc.getByRequestId request._id, (e, orders) =>
        if e then return callback e
        callback null,
          session:  @session usr
          request:  JSON.stringify request
          orders:   JSON.stringify orders

  callEdit: (callId, callback) ->
    rSvc.getByCallId callId, (e, request) =>
      oSvc.getByRequestId request._id, (e, orders) =>
        if e then return callback e
        callback null,
          session: @session usr
          request: JSON.stringify request
          orders: JSON.stringify orders

  book: (id, code, callback) ->
    eSvc.getByBookme id, (e, r) =>
      if code? && r._id?
        r.bookMe.code = "invalid code"
        for coupon in r.bookMe.coupons
          if coupon.code == code
            r.bookMe.code = code
            r.bookMe.rate = coupon.rate
      if r._id?
        # delete r.bookMe.rake
        delete r.bookMe.coupons
      if e then return callback e
      callback null,
        isAnonymous:  !usr?
        session:      @session usr
        expert:       r
        expertStr:    JSON.stringify r
        stripePK:     cfg.payment.stripe.publishedKey
        # settings:     srs    ## settings crashes app for some reason

  bookme: (callback) ->
    token = if usr.github.token? then usr.github.token.token else ''
    eSvc.getByBookmeByUserId usr._id, (e, r) =>
      if e then return callback e
      callback null,
        githubToken:  token
        session:      @session usr
        expert:       r
        expertStr:    JSON.stringify r

  pipeline: (cb) ->
    new RequestsSvc(@usr).getActive (e, requests) =>
      cb e, -> { requests }

  orders: (cb) ->
    new OrdersSvc(@usr).getAll (e, orders) =>
      cb e, -> { orders }

  experts: (cb) ->
    new ExpertsSvc(@usr).getAll (e, experts) =>
      cb e, -> { experts }

  companys: (cb) ->
    new CompanysSvc(@usr).getAll (e, companys) =>
      cb e, -> { companys, stripePK }

  # stripeCharge: (orderId, token, callback) ->
  #   oSvc.markPaymentReceived orderId, usr, {}, (e, o) =>
  #     if e then return callback e
  #     callback null,
  #       session: @session usr
  #       order: JSON.stringify null, o
  #       stripePK: cfg.payment.stripe.publishedKey

  paypalSuccess: (orderId, callback) ->
    oSvc.markPaymentReceived orderId, usr, {}, (e, o) =>
      if e then return callback e
      callback null,
        session: @session usr
        order: JSON.stringify o

  paypalCancel: (orderId, callback) ->
    oSvc.getById orderId, (e, o) =>
      if e then return callback e
      callback null,
        session: @session usr
        order: JSON.stringify o

  history: (id, callback) ->
    rSvc.getForHistory custUserId, (e,r) =>
      oSvc.getForHistory custUserId, (ee,o) =>
        callback null,
          session: @session usr
          requests: JSON.stringify r
          orders: JSON.stringify o
          isAdmin: Roles.isAdmin(usr).toString()

