# async            = require 'async'
# TagsSvc          = require '../services/tags'
OrdersSvc        = require '../services/orders'
ExpertsSvc       = require '../services/experts'
CompanysSvc      = require '../services/companys'
# SettingsSvc      = require '../services/settings'
RequestsSvc      = require '../services/requests'
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
        _.pick u, ['_id','google','googleId','authenticated']
    else
      authenticated : false

  settings: (cb) ->
    cb null, -> { stripePK }

  review: (id, cb) ->
    new RequestsSvc(@usr).getByIdSmart id, (e, request) =>
      cb e, -> { request }

  callSchedule: (requestId, cb) ->
    new RequestsSvc(@usr).getById requestId, (e, request) =>
      new OrdersSvc(@usr).getByRequestId request._id, (ee, orders) =>
        cb ee, -> { request, orders }

  callEdit: (callId, cb) ->
    new RequestsSvc(@usr).getByCallId callId, (e, request) =>
      new OrdersSvc(@usr).getByRequestId request._id, (ee, orders) =>
        cb ee, -> { request, orders }

  book: (id, code, cb) ->
    new ExpertsSvc(@user).getByBookme id, code, (e, expert) =>
      cb e, -> { expert, stripePK }

  history: (id, cb) ->
    new RequestsSvc(@usr).getForHistory id, (e,requests) =>
      new OrdersSvc(@usr).getForHistory id, (ee,orders) =>
        cb ee, -> { orders, requests }

  bookme: (cb) ->
    githubToken = if @usr.github.token? then @usr.github.token.token else ''
    new ExpertsSvc(@usr).getByBookmeByUserId @usr._id, (e, expert) =>
      cb e, -> { expert, githubToken }

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

  paypalSuccess: (id, cb) ->
    new OrdersSvc(@usr).markPaymentReceived id, {}, (e, order) =>
      cb e, -> { order }

  paypalCancel: (id, cb) ->
    new OrdersSvc(@usr).getById id, (e, order) =>
      cb e, -> { order }

  # stripeCharge: (orderId, token, callback) ->
  #   oSvc.markPaymentReceived orderId, usr, {}, (e, o) =>
  #     if e then return callback e
  #     callback null,
  #       session: @session usr
  #       order: JSON.stringify null, o
  #       stripePK: cfg.payment.stripe.publishedKey

